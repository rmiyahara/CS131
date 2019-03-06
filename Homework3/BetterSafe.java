import java.util.concurrent.locks.ReentrantLock;

class BetterSafe implements State {
    private byte[] value;
    private byte maxval;
    private ReentrantLock hold_me = new ReentrantLock(); //Locks critical code

    BetterSafe(byte[] v) { value = v; maxval = 127; }

    BetterSafe(byte[] v, byte m) { value = v; maxval = m; }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
        hold_me.lock(); //Begin critical code
	    if (value[i] <= 0 || value[j] >= maxval) {
            hold_me.unlock(); //LOL I FORGOT THIS IM DUMB
	        return false;
	    }
	    value[i]--;
	    value[j]++;
        hold_me.unlock(); //End critical code
	    return true;
    }
}