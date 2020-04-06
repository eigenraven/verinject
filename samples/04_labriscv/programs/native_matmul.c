#include <stdio.h>

static const int mat1[36] = {
    261, -652, -831, 55, -179, -385, 354, 326, -20, -821, 385, -666, 126, -45, -718, -817, 254, -386, -903, -205, 27, -133, -169, 363, 252, 163, 264, -200, 295, 913, 968, 109, -31, -66, -458, 970};
static const int mat2[36] = {
    631, 818, -253, -815, 893, 445, 352, 474, -142, 631, -258, 997, 477, -934, -718, 779, -114, -1021, 882, -692, 832, -10, 994, 643, 283, 205, -556, -751, -47, -495, -230, -934, -165, -815, 150, 52};

__attribute__((always_inline)) inline int idx(int r, int c)
{
    return 6 * r + c;
}

int main()
{
    int matR[36] = {0};
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
    for (int i = 0; i < 36; i++)
    {
        printf("%08x,", matR[i]);
    }
    printf("\n");
    return 0;
}
