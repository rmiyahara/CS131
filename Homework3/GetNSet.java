import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSet(byte[] v) {
        maxval = (byte) 127;
        int n = v.length; //Reduce overhead
        value = new AtomicIntegerArray(n);
        for(int i = 0; i < n; i++) { //Set values to match v
            value.set(i, v[i]);
        }
    }

    GetNSet(byte[] v, byte m) {
        maxval = m;
        int n = v.length; //Reduce overhead
        value = new AtomicIntegerArray(n);
        for(int i = 0; i < n; i++) { //Set values to match v
            value.set(i, v[i]);
        }
    }

    public int size() { return value.length(); }

    public byte[] current() {
        int n = size(); //Reduce overhead
        byte[] result = new byte[size()]; //Puts values into a byte array and returns it
        for(int i = 0; i < n; i++) {
            result[i] = value.get(i);
        }
        return result;
    }

    public boolean swap(int i, int j) {
        if(value.get(i) <= 0 || value.get(j) >= maxval) {
            return false;
        }
        value.getAndSet(i, (value.get(i) - 1));
        value.getAndSet(j, (value.get(j) + 1));
        return true;
    }
}