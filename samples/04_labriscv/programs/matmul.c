__attribute__((section(".text.startup")))
void _start();
void init_mats(int* mat1, int* mat2);

__attribute__((always_inline)) inline void write_led_port(int value)
{
    __asm__ volatile(
        "csrw 0x7C1, %0"
        :
        : "r"(value)
        : "memory");
}

__attribute__((always_inline)) inline void write_ssd_port(int value)
{
    __asm__ volatile(
        "csrw 0x7C2, %0"
        :
        : "r"(value)
        : "memory");
}

__attribute__((always_inline)) inline void use_value(int *value)
{
    __asm__ volatile(
        ""
        :
        : "g"(value)
        : "memory");
}


__attribute__((always_inline)) inline int idx(int r, int c)
{
    return 6 * r + c;
}

__attribute__((section(".text.startup")))
__attribute__((naked)) void _start()
{
    __asm__ volatile(
        "li sp, 0x2300"
        :
        :
        : "memory");
    write_led_port(1);
    volatile int *matR = (int *)((void *)0x2000);
    int* mat1 = (int *)((void *)0x2090);
    int* mat2 = (int *)((void *)0x2120);
    init_mats(mat1, mat2);
    write_led_port(2);
    use_value(0); // prevents reordering
    for (int rr = 0; rr < 6; rr++)
    {
        for (int rc = 0; rc < 6; rc++)
        {
            int dot = 0;
            for (int e = 0; e < 6; e++)
            {
                dot += mat1[idx(rr, e)] * mat2[idx(e, rc)];
            }
            matR[idx(rr, rc)] = dot;
        }
    }
    use_value(0);
    write_led_port(3);
    while (1)
    {
        __asm__ __volatile__(""
                             :
                             :
                             : "memory");
    }
}
/*
static const int mat1[36] = {
    261, -652, -831, 55, -179, -385, 354, 326, -20, -821, 385, -666, 126, -45, -718, -817, 254, -386, -903, -205, 27, -133, -169, 363, 252, 163, 264, -200, 295, 913, 968, 109, -31, -66, -458, 970};
static const int mat2[36] = {
    631, 818, -253, -815, 893, 445, 352, 474, -142, 631, -258, 997, 477, -934, -718, 779, -114, -1021, 882, -692, 832, -10, 994, 643, 283, 205, -556, -751, -47, -495, -230, -934, -165, -815, 150, 52};
*/

// avoid putting things into .data
void init_mats(int* mat1, int* mat2)
{
    int i = 0;
    mat1[i++] = 261;
    mat1[i++] = -652;
    mat1[i++] = -831;
    mat1[i++] = 55;
    mat1[i++] = -179;
    mat1[i++] = -385;
    mat1[i++] = 354;
    mat1[i++] = 326;
    mat1[i++] = -20;
    mat1[i++] = -821;
    mat1[i++] = 385;
    mat1[i++] = -666;
    mat1[i++] = 126;
    mat1[i++] = -45;
    mat1[i++] = -718;
    mat1[i++] = -817;
    mat1[i++] = 254;
    mat1[i++] = -386;
    mat1[i++] = -903;
    mat1[i++] = -205;
    mat1[i++] = 27;
    mat1[i++] = -133;
    mat1[i++] = -169;
    mat1[i++] = 363;
    mat1[i++] = 252;
    mat1[i++] = 163;
    mat1[i++] = 264;
    mat1[i++] = -200;
    mat1[i++] = 295;
    mat1[i++] = 913;
    mat1[i++] = 968;
    mat1[i++] = 109;
    mat1[i++] = -31;
    mat1[i++] = -66;
    mat1[i++] = -458;
    mat1[i++] = 970;
    i = 0;
    mat2[i++] = 631;
    mat2[i++] = 818;
    mat2[i++] = -253;
    mat2[i++] = -815;
    mat2[i++] = 893;
    mat2[i++] = 445;
    mat2[i++] = 352;
    mat2[i++] = 474;
    mat2[i++] = -142;
    mat2[i++] = 631;
    mat2[i++] = -258;
    mat2[i++] = 997;
    mat2[i++] = 477;
    mat2[i++] = -934;
    mat2[i++] = -718;
    mat2[i++] = 779;
    mat2[i++] = -114;
    mat2[i++] = -1021;
    mat2[i++] = 882;
    mat2[i++] = -692;
    mat2[i++] = 832;
    mat2[i++] = -10;
    mat2[i++] = 994;
    mat2[i++] = 643;
    mat2[i++] = 283;
    mat2[i++] = 205;
    mat2[i++] = -556;
    mat2[i++] = -751;
    mat2[i++] = -47;
    mat2[i++] = -495;
    mat2[i++] = -230;
    mat2[i++] = -934;
    mat2[i++] = -165;
    mat2[i++] = -815;
    mat2[i++] = 150;
    mat2[i++] = 52;
}
