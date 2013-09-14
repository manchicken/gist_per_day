/* This was my answer to this question: http://stackoverflow.com/questions/18432801/trying-to-insert-element-in-an-array-using-pointers-but-not-successfull/18432920#18432920 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

void insert(int*,int);

void main()
{
    int a[10];
    int i,n,pos,x,j,z;
//    clrscr();
    printf("Enter Size Of an array: ");
    scanf("%d",&n);
    printf("Enter Elements of an array: ");
    for(i=0;i<n;i++)
    {
        scanf("%d",a+i);
    }
    insert(a,n);
    printf("\nArray after Insertion of elements at 2nd & 5th Position\n");
    for(i=0;i<n;i++)
    {
        printf("\t%d\t",*(a+i));
    }
 //   getch();
}

void insert(int *b, int n)
{
    if(n>=1)
    {
        printf("Insert Element at 2nd Position: ");
        scanf("%d",b+1);
    }
    if(n>=4)
    {
        printf("Insert Element at 5th Position: ");
        scanf("%d",b+4);
    }
}
