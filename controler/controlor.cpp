#include <iostream>
#include <fstream>
#include <cstdio>
#include <conio.h>
#include <windows.h>
using namespace std;

char add(char);
void del(char);

int main()
{
    char current_press, last_press = '\0';
    bool pause = 0;
    cout<<"-------------------CONTROLOR--------------------\n";
    cout<<"---Press J to jump,\n---or K to squat,\n---or L to pause";
    cout<<"------------------------------------------------\n";
    del('j');
    del('k');
    del('l');
    while (true)
    {
        while(kbhit())
        {
            current_press = getch();
            if (current_press == 'l')
            {
                if (pause)
                {
                    del('l');
                    pause = 0;
                }else
                {
                    add('l');
                    pause = 1;
                }
                break;
            }
            if (current_press != last_press)
            {
                del(last_press);
                last_press = add(current_press); 
                Sleep(400);
            }
            Sleep(100);
        }
            del(last_press);
        last_press = '\0';
        Sleep(10);
    }
}

ofstream creater;

char add(char x)
{
    switch (x)
    {
    case 'j':
        creater.open("detect_zone\\jump", ios::out);
        creater.close();
        cout<<"Jump!"<<endl;
        break;
    case 'k':
        creater.open("detect_zone\\squat", ios::out);
        creater.close();
        cout<<"Squating."<<endl;
        break;
    case 'l':
        creater.open("detect_zone\\pause", ios::out);
        creater.close();
        cout<<"PAUSE"<<endl;
        break;
    default:
        break;
    }
    return x;
}

void del(char x)
{
    switch (x)
    {
    case 'j':
        remove("detect_zone\\jump");
        break;
    case 'k':
        remove("detect_zone\\squat");
        break;
    case 'l':
        remove("detect_zone\\pause");
        break;
    default:
        break;
    }
}