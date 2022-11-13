struct barr{
    uint count;
    struct sleeplock barr_lock;
    struct cond_t cv;
};

struct buff{
    int x;
    int full;
    struct sleeplock buff_lock;
    struct cond_t inserted;
    struct cond_t deleted;
};
