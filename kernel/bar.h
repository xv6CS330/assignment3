struct barr{
    uint count;
    struct sleeplock barr_lock;
    struct cond_t cv;
}