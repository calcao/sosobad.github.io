## 功能
Condition接口提供了类似Object类自带的监视器方法（wait(), wait(long timeout), notify(), notifyAll()，与Lock配合可以实现等待/通知模式


## 使用示例
```java
public class ConditionTest {

    private final Lock lock = new ReentrantLock();

    private final Condition condition = lock.newCondition();


    public void conditionAwait(){
        lock.lock();
        try{
            String name = Thread.currentThread().getName();
            System.out.printf("%s获取到锁\n", name);
            System.out.printf("%s等待信号\n", name);
            condition.await();
            System.out.printf("%s收到信号\n", name);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }



    public void conditionSignal(){
        lock.lock();
        try {
            String name = Thread.currentThread().getName();
            System.out.printf("%s获取到锁\n", name);
            System.out.printf("%s发出信号\n", name);
            condition.signal();
        }finally {
            lock.unlock();
        }
    }


    public void conditionSignalAll(){
        lock.lock();
        try {
            String name = Thread.currentThread().getName();
            System.out.printf("%s获取到锁\n", name);
            System.out.printf("%s发出信号\n", name);
            condition.signalAll();
        }finally {
            lock.unlock();
        }
    }


    public static void main(String[] args) {

        ConditionTest conditionTest = new ConditionTest();

        new Thread(() -> conditionTest.conditionAwait(), "test-1").start();

        new Thread(() -> conditionTest.conditionAwait(), "test-2").start();

        // 唤醒一个等待线程
        // new Thread(() -> conditionTest.conditionSignal(), "test-3").start();

        // 唤醒所有等待线程
        new Thread(() -> conditionTest.conditionSignalAll(), "test-4").start();
    }
    
}
```
输出：
```bash
test-1获取到锁
test-1等待信号
test-2获取到锁
test-2等待信号
test-4获取到锁
test-4发出信号
test-1收到信号
test-2收到信号
```

## 原理
+ ConditionObject是AbstractQueueSynchronizer的内部类，每个Condition内部包含一个等待队列
+ 等待队列是一个FIFO队列，每个节点都包含一个线程的引用，该线程即在Condition对象上等待的对象
+ 调用await()方法会使线程进入等待队列，并释放锁，同时线程状态变为等待状态，相当于从AQS中同步队列的首节点移动到Condition的等待队列中

