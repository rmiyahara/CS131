import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSet(byte[] v) { value = v; maxval = 127; }

    GetNSet(byte[] v, byte m) {
        int n = v.length; //Reduce overhead
        value = new AtomicIntegerArray(n);
        for (int i = 0; i < n; i++) {
            //TODO: Set values
        }
        //TODO: Check values are less than m
        //TODO: Set m
    }
}