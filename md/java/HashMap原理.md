# Java8中HashMap原理


## JDK7和JDK8中HashMap的不同点
+ JDK8中引入了新的数据结构红黑树
+ JDK7中链表的插入使用头插法，扩容转移元素也是用的头插法，头插法速度更快，无需遍历链表，但是再多线程扩容的情况下使用头插法会出现循环链表问题，导致CPU飙升，JDK8中链表添加元素使用尾插法，JDK8中需要统计链表节点个数，所以要遍历链表，所以使用尾插法
+ JDK7中的Hash算法比JDK8中更复杂，生成的hashcode也更散列，hashMap中的元素也更散列，而JDK8中引入了红黑树，查询性能得到保障，所以简化了Hash算法，毕竟算法越复杂越消耗CPU
+ 扩容的过程中，JDK7有可能会对Key进行rehash,重新hash与哈希种子有关，而JDK8中没有这部分逻辑
+ JDK8中扩容条件与JDK7中不一样，除了要判断size是否大于阈值外，JDK7中海需要判断tab[i]是否为空，不为空才会扩容，而JDK8中没有该条件
+ JDK8中多了一个API: putIfAbsent(key, value)
+ JDK7和JDK8扩容中转移元素的逻辑不一样，JDK7是每次转移一个元素，JDK8是先算出来当前位置上哪些元素在新数组的低位上，哪些在新数组的高位上，再一次性转移 

## 为什么使用红黑树
+ 当元素隔宿小于某个阈值时，链表的插入查询效率要高于红黑树，当元素个数大于阈值时，链表的效率要低于红黑树
+ AVL树插入效率低，因此选择插入效率较高的红黑树
+ 链表的查询的时间复杂度为O(n), 而红黑树的查询时间复杂度为O(logN)

## 什么时候会转化为红黑树
当链表长度大于等于8时，并且数组长度大于等于64时才会转化为红黑树，当链表长度小于64时，通过扩容来减小hash冲突，缩短链表长度


## 红黑树定义
+ 节点包含两种颜色，不是红就是黑
+ 根节点是黑色
+ 叶子节点是黑色
+ 一个节点是红色，则孩子节点是黑色
+ 每个节点到叶子节点所有的路径上黑色节点总数相同
+ 新节点默认黑色


## 加载因子
加载因子表示数组的填满程度
加载因子 = 填入表中的元素个数 / 散列表的长度
加载因子越大，填满的元素越多，空间利用率越高，但发生冲突的机会变大了；
加载因子越小，填满的元素越少，冲突发生的机会减小，但空间浪费了更多了，而且还会提高扩容rehash操作的次数

### 解决Hash冲突方法
1. 开放地址法
2. 再哈希法
3. 公共溢出区
4. 拉链法


## 源码解读

### 相关内部属性
```java
//  默认容量位16 2^4
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; 

//  最大容量 2^30
static final int MAXIMUM_CAPACITY = 1 << 30

//  默认负载因子 
static final float DEFAULT_LOAD_FACTOR = 0.75f;

// 树化阈值
static final int TREEIFY_THRESHOLD = 8;

// 由红黑树退化位链表阈值
static final int UNTREEIFY_THRESHOLD = 6;

// 链表树化Node数组需要达到的最小容量
// 当数组小于64时，会通过扩容来解决冲突
static final int MIN_TREEIFY_CAPACITY = 64;

//  Node继承自Map.Entry内部类，存放
transient Node<K,V>[] table;

// 保存keySet()和values()的迭代器
transient Set<Map.Entry<K,V>> entrySet;

// 记录元素个数
transient int size;

// 记录当前集合的修改次数，添加删除都会影响
transient int modCount;

// 下次扩容的阈值
// threshold = capacity * loadfacor
int threshold;

// 负载因子
final float loadFactor;
```


### 添加元素过程

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        // 【1】 检查table数组是否初始化
        if ((tab = table) == null || (n = tab.length) == 0)
            // resize方法同时承担初始化和扩容功能
            n = (tab = resize()).length;
        // 【2】 根据hash值定位数组下标，并判断数组位置是否为空
        if ((p = tab[i = (n - 1) & hash]) == null)
            // 如果为空则直接在该位置新建一个node, 添加操作结束
            tab[i] = newNode(hash, key, value, null);
        else {
            // 如果该位置不为空，则需要做进一步判断
            Node<K,V> e; K k;
            // 【3】 无论链表还是红黑树，先判断第一个节点Key与需要添加的key是否一致
            //       如果一致则需要添加的元素就是该数组位置第一个元素，到【6】覆盖old vlaue
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            // 【4】 如果第一个元素不是需要添加元素位置，则需再判断当前数组位置时链表还是红黑树
            else if (p instanceof TreeNode)
                // 如果为红黑树，则调用TreeNode自身的putTreeVal方法添加元素，返回元素所在的TreeNode
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            // 【5】如果为链表
            else {
                // 循环单向链表
                for (int binCount = 0; ; ++binCount) {
                    // binCount为链表元素数量统计
                    // 这里使用的时尾插法
                    if ((e = p.next) == null) {
                        // 当循环到链表尾部时，新建链表节点
                        p.next = newNode(hash, key, value, null);
                        // 当链表元素超过树化阈值 （binCount从0开始，因此这里判断阈值-1）时
                        // 将链表树化
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            // 树化方法中还会进一步判读table长度是否>=64
                            // 达到64才会树化，否则进行扩容操作
                            treeifyBin(tab, hash);
                        break;
                    }
                    // 如果再链表循环中，找到一致的key，则返回节点，跳出循环
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            // 【6】赋值
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                // 插入操作的callback方法， 方便LinkedHashMap做操作
                afterNodeAccess(e);
                return oldValue;
            }
        }
        
        // 增加操作记录
        ++modCount;

        // 增加元素个数
        // 判断是否达到扩容阈值，达到则进行扩容操作
        if (++size > threshold)
            resize();
        // 插入操作的callback方法， 方便LinkedHashMap做操作
        afterNodeInsertion(evict);
        return null;
    }
```



