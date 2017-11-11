#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MAX_DAYS 30

struct day_type
{
  char day[128];
  char open[128];
  char high[128];
  char low[128];
  char close[128];
  char volume[128];
  char cap[128];
};

char  *ptr, buffer[16392], cmd[512];
char  company_name[128], zipcode[64];
char  wind_speed[64], wind_direction[64];
char  us_state[32], us_city[128], tod[64];
int   i, n, first_time, indx, state;

struct day_type days[MAX_DAYS];

int main(int argc, char *argv[])
{
  FILE *fp;
  
  sprintf(cmd,
    "wget -qO- https://coinmarketcap.com/currencies/bitcoin/historical-data/");

    if((fp = popen(cmd, "r")) != NULL)
    {
      state = 0;

      while (!feof(fp))
      {
        if (fgets(buffer,sizeof(buffer) - 1, fp) != NULL)
        {
          switch (state)
          {
            case 0:
            if (strstr(buffer, "<div class=table-responsive>") != NULL)
            {
              i = 0;
              state = 1;
            }
            break;

            case 1:
              if (strstr(buffer,"<td class=\"text-right\">") != NULL)
              {
                if ((ptr = strstr(buffer, "<-left\">")) != NULL)
                {
                  ptr +=3;
                  indx = 0;

                  while (*ptr != '<')
                  {
                    days[i].day[indx] = *ptr;
                    indx++;
                    ptr++;
                  }
                  state = 2;
                }
                printf("%s", *ptr);
              }
            break;
          }
        }
      }
    }
	pclose(fp);
}
