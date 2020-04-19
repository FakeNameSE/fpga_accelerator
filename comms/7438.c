


#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <termio.h>
#include <signal.h>

#ifndef assign_errno
#define assign_errno(x)     ((errno != 0) ? errno : (x))
#endif

#ifndef FALSE
#define FALSE (0)
#endif

#ifndef TRUE
#define TRUE  (1)
#endif

extern int errno;

#define QUEST "???"

static int verbose = FALSE;
static int port_fdes = -1;
static char *arg0 = NULL;

typedef struct
  {
    char *desc;
    unsigned short speed;
    int is_default;
  } speed_rec;

static speed_rec speeds[] =
  {
    {"0"        , B0        , FALSE},
    {"50"       , B50       , FALSE},
    {"75"       , B75       , FALSE},
    {"110"       ,B110      , FALSE},
    {"300"       ,B300      , FALSE},
    {"600"       ,B600      , FALSE},
    {"1200"      ,B1200     , FALSE},
    {"2400"      ,B2400     , FALSE},
    {"4800"      ,B4800     , FALSE},
    {"9600"      ,B9600     , FALSE},
    {"19200"     ,B19200    , TRUE },
    {"38400"     ,B38400    , FALSE},
    {NULL        ,0         , FALSE}
  }; 
   
static struct termio tm =
  {
    (IGNBRK | IXON | IXOFF),                                /* c_iflag */ 
    0,                                                      /* c_oflag */
    (CLOCAL | CREAD | CS8 | HUPCL),                         /* c_cflag */
    0,                                                      /* c_lflag */
    '\0'                                                    /* c_line  */
   };

static void init_c_cc(struct termio *x, int speed)
{
  int i = 0;

  for (i = 0; i < NCC; ++i) x->c_cc[i] = '\0';
  x->c_cc[VINTR] = CINTR;
  x->c_cc[VEOF] = 4;
  x->c_cflag |= (unsigned short) speed;
  return;
}        

static void problem(char *msg, int err)
{
  (void) fprintf(stderr,"%s: \n%s (%d)\n",arg0,msg,err);
  (void) fflush(stderr);
  return;
} /* problem */

static void close_n_exit(int sig)
{
  if (port_fdes >= 0)
    {
      (void) close(port_fdes);
       port_fdes = -1;
    }
  exit(sig);
  return;
} /* close_n_exit */

int hold_the_port(char *fname,int do_exit)
{
  int cc = 0;
  char s_err[1024];

  s_err[0] = '\0';
  if (verbose)
    {
      (void) printf("Opening device '%s'\n",fname);
      (void) fflush(stdout);
    }
  port_fdes = open(fname,O_RDWR | O_NDELAY,0666);
  if (port_fdes >= 0)
    {
      if (verbose)
        {
          (void) printf("Setting port speed and attributes. ...\n");
          (void) fflush(stdout);
        }
      cc = ioctl(port_fdes,TCSETA,&tm);
      if (cc == 0)
        {
          if (!do_exit)
            {
              (void) signal(SIGINT,SIG_IGN);
              (void) signal(SIGHUP,SIG_IGN);
              (void) signal(SIGTERM,close_n_exit);
/*CONSTCOND*/
              while (TRUE) (void) pause(); 
            }
        }
      else
        {
          cc = assign_errno(-3);
          problem("TCSETA failed",cc);
        }                       
      (void) close(port_fdes);
    }
  else
    {
      cc = assign_errno(-1);
      (void) sprintf(s_err,"Can't open file '%s'.\n",fname);
      problem(s_err,cc);
    }
  return(cc);
} /* hold_the_port */


static int usage(void)
{
  int i = 0;
  char *p = NULL;

  (void) fprintf(stderr,"\nUsage: %s -t device_file [-s speed]\n\n",arg0);
  (void) fprintf(stderr,"    -t device_file - the desired TTY port\n\n");
  (void) fprintf(stderr,"    -s speed  one of the following baudrates:\n");
  while (speeds[i].desc != NULL)
    {
      p = (speeds[i].is_default) ? "(default)" : "";
      (void) fprintf(stderr,"      %s    %s\n",speeds[i].desc,p);
      ++i;
    }
  (void) fflush(stderr);
  return(1);
} /* usage */

static int get_speed(char *key)
{
  int i = 0,fnd = FALSE,speed = -1;

  if (key != NULL)
    {
      while (speeds[i].desc != NULL && !fnd)
        {
          fnd = (strcmp(speeds[i].desc,key) == 0);
          if (!fnd) ++i; 
        }
    } 
  else
    {
      while (speeds[i].desc != NULL && !fnd)
        {
          fnd = speeds[i].is_default; 
          if (!fnd) ++i; 
        }
    }
  if (fnd) speed = speeds[i].speed;
  return(speed);
} /* get_speed */

int main(int argc, char *argv[])
{
  int cc = 0,c = 0;
  char *tfile = NULL,*s_speed = NULL;
  extern char *optarg;

  arg0 = argv[0];
  while (c != -1)
    {
      c = getopt(argc,argv,"t:s:v");
      if (c != -1)
        {
          switch(c)
            {
              case 't':
                tfile = optarg;
                break;
              case 's':
                s_speed = optarg;
                break;
              case 'v':
                verbose = TRUE;
                break;
              case ':':
              case '?':
                cc = usage();
                c = -1;
                break;
            } /* switch */
        }
    } 
  if (cc == 0)
    {
      int term_speed = 0;

      term_speed = get_speed(s_speed);
      if (term_speed >= 0)
        {
          init_c_cc(&tm,term_speed);
          if (tfile != NULL)
            {
              cc = access(tfile,R_OK | W_OK);
              if (cc == 0)
                {
                  pid_t pid = 0;

                  pid = fork();
                  if (pid >= 0)
                    {
                      if (pid == 0) cc = hold_the_port(tfile,
                                                       (term_speed == B0));
                      else return(0);
                    } 
                  else
                    {
                      cc = assign_errno(-11);
                      problem("Can't fork process",cc);
                    }
                }
              else
                {
                  char s_err[1024];

                  cc = assign_errno(-10);
                  (void) sprintf(s_err,
                             "Can't access device file '%s' for read/write.",
                                 tfile);  
                  problem(s_err,cc);
               }  
            }
          else cc = usage();
        }
      else
        {
          cc = -5;
          problem("Invalid baudrate",cc);
        }

    }                      
  return(cc);
}


