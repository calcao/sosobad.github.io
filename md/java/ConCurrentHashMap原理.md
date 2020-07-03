## JDK7中ConCurrentHashMap数据结构
+ Segment和HasEntry的嵌套数组 + 链表 + 红黑树，ConCurrentHashMap内部包含一个属性segments，类型为Segment[]，Segment内部包含一个属性table，类型为HashEntry[]

## JDK7中ConcurrentHashMap插入过程
+ 先根据key计算Segment数组下标，如果当前Semgent数组位置为空，则通过自旋方式在该位置添加一个新的Segment对象，再调用Segment的put方法，先加锁，通过key计算元素在HashEntry数组中的位置，然后添加到指定位置，此过程和JDK7中HashMap添加元素过程一致，添加成功后解锁。
+ 加锁过程：先通过tryLock()自旋加锁，超过一定次数后就会通过lock()阻塞加锁


## JDK7中ConCurrentHashMap如何保证并发
+ Unsafe操作(CAS乐观锁) + ReentrantLock + 分段思想
+ 主要使用了Unsafe操作中的：
    - compareAndSwapObject: 通过CAS方式修改对象属性
    - putOrderObject: 并发安全的给数组某个位置赋值
    - getObjectVolatile: 并发安全的获取数组某个位置值
+ 分段思想主要是为了提高并发，分段数越高支持的并发数量越高，可以通过修改concurrencyLevel参数来指定
+ ConcurrentHashMap内部Segment就是一个分段，每个Segment相当于一个小型的HashMap，当调用ConcurrentHashMap的put方法时，最终会调用Segment的put方法，而Segment继承了ReentrantLock，所以调用Segment的put方法时会使用RentrantLock加锁，加锁成功后再插入key，val，添加成功后解锁


## JDK8中ConcurrentHashMap数据结构
+ 数组 + 链表 + 红黑树


## JDK8中ConcurrentHashMap插入过程
+ 根据key计算数组下标，如果该位置为空，则通过自旋方式像该位置赋值
+ 如果该位置有元素存在，则通过synchronized加锁
+ 加锁成功后，判断元素类型，链表or红黑树，通过各自方法添加元素
+ 添加成功后，判断是否需要树化
+ 然后addCount，统计ConncurrentHashMap中元素， 元素个数+1成功后会继续判断是否需要扩容
+ 同时有另一个线程在put时发现节点对象hascode为-1，则表示正在扩容，则会去帮助扩容



## JDK8中ConCurrentHashMap如何保证并发
+ Unsafe操作 + Synchronized
+ Unsafe是在给数组上某个位置为空时，赋值使用
+ Synchronized是在给数组上某个位置的链表或红黑树修改元素时使用




