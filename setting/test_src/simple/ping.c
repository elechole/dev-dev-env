#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <sys/time.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/in.h>

#include	<time.h>	//	CLOCK_REALTIME

#define BUFSIZE 4096

int  seqnum;              // ping 메시지 일련번호
char recvbuf[ BUFSIZE ];  // 수신버퍼
char sendbuf[ BUFSIZE ];  // 송신버퍼
int  rawsock;             // Raw 소켓 번호
int  notrecv = 0;         // ping 응답을 받지 못한 회수
struct timeval atime;
struct timespec	ts;

int    diff1;
int    diff2;

struct sockaddr_in sendaddr, recvaddr;

int 		   send_ping();                                     // ping request
int 		   prn_rcvping( char *ipdata, int recvsize );       // ping 응답에 출력
void 		   prn_icmp( struct icmphdr  *icmp, int icmpsize ); // ICMP 헤더 출력
unsigned short in_cksum( unsigned short *addr, int len );       // ICMP Check sum

void 		   errquit(char *msg) 
{ 
	perror(msg); 
	exit(0); 
}

int main( int argc, char **argv ) 
{
	int recvsize, addrlen = sizeof( struct sockaddr );
	fd_set readset;
	struct timeval tv;
	int ret;
	struct timeval ltime;

	struct	hostent	*host_entry;
	int idx;
	char	*ipAddr;

	if( argc != 2 ) 
	{
		printf( "Usage : %s  ip_address \n", argv[ 0 ] );
		exit( 1 );
	}

	host_entry = gethostbyname( argv[ 1 ] );

	if( host_entry == NULL )
	{
		printf( "FAILED: gethostbyname() !!!\n" );
		exit( 1 );
	}

	for( idx = 0 ; host_entry->h_addr_list[ idx ] != NULL ; idx++ )
	{
		printf( "%d: %s\n", idx, inet_ntoa( *( struct in_addr * )host_entry->h_addr_list[ idx ] ) );
	}
	
	ipAddr = inet_ntoa( *( struct in_addr * )host_entry->h_addr_list[ 0 ] );

	addrlen = sizeof( struct sockaddr );
	bzero( &recvaddr, sizeof( struct sockaddr ) );
	bzero( &sendaddr, sizeof( struct sockaddr ) );

	sendaddr.sin_family = AF_INET;
	//inet_pton( AF_INET, argv[ 1 ], &sendaddr.sin_addr.s_addr );
	inet_pton( AF_INET, ipAddr, &sendaddr.sin_addr.s_addr );
	sendaddr.sin_port = htons( 0 );

	// raw 소켓 생성
	rawsock = socket( AF_INET, SOCK_RAW, IPPROTO_ICMP );
	if( rawsock < 0 ) errquit( "socket fail" );

	// 커널에 상대의 주소를 기억해둠
	if( connect( rawsock, ( struct sockaddr* )&sendaddr, sizeof( struct sockaddr) ) != 0 )
		errquit("connect fail ");

	// 첫번째 ping 보내기
	while( 1 ) 
	{
		FD_ZERO( &readset );
		FD_SET( rawsock, &readset );
		tv.tv_sec  = 1; // 1초 타이머
		tv.tv_usec = 0;

		send_ping();    // ping을 보냄

		ret = select( rawsock + 1, &readset, NULL,NULL,&tv ); // 타이머 가동
		if( ret == 0 ) 
		{    // 타임아웃
			if( ++notrecv == 3 ) 
			{
				notrecv = 0;
				puts( "Request Timeout ... " );
			}
			continue;
		}
		else if( ret < 0 ) // select()의 에러
			errquit("select fail");

		// select()의 정상리턴, ping 응답을 읽음
		recvsize = recvfrom( rawsock, recvbuf, sizeof( recvbuf ),0, (struct sockaddr*)&recvaddr, &addrlen );

		if( recvsize < 0 )	errquit("recvfrom fail ");

		notrecv = 0; // 수신된 응답에 대한 처리

		//gettimeofday( &atime, NULL );
		//diff2 = ( ( atime.tv_sec % 100 ) * 1000 ) + ( atime.tv_usec / 1000 );

		clock_gettime( CLOCK_REALTIME, &ts );
		diff2 = ( ( ts.tv_sec % 100 ) * 1000000 ) + ( ts.tv_nsec / 1000 );

		int subtime = diff2 - diff1;
		ltime.tv_sec  = subtime / 1000000;
		ltime.tv_usec = subtime % 1000000;
		printf( "%d sec, %d usec\n", ( int )ltime.tv_sec, ( int )ltime.tv_usec );

		prn_rcvping( recvbuf, recvsize );

		sleep( 1 );// 1초 간격으로 ping을 보냄
	}
	exit( 0 );
}

void prn_icmp( struct icmphdr  *icmp, int icmpsize ) 
{
	printf( "[icmp](id:%d ", icmp->un.echo.id       );
	printf( "seq:%d "      , icmp->un.echo.sequence );
	printf( "code:%d "     , icmp->code             );
	printf( "type:%d )\n"  , icmp->type             );
}

// 수신된 메시지를 출력
int prn_rcvping( char *ipdata, int recvsize ) 
{
	int             ip_headlen, icmp_len;
	struct icmphdr* icmp;
	struct iphdr*   ip;
	char            buf[ 512 ];

	ip         = (struct iphdr*)ipdata;
	ip_headlen = ip->ihl * 4;
	icmp_len   = recvsize - ip_headlen;
	icmp       = (struct icmphdr *)( ipdata + ip_headlen );

	if ( icmp->type != ICMP_ECHOREPLY )		return -1;

	inet_ntop( AF_INET,(void*)&ip->saddr, buf, sizeof( buf ) );
	printf( "%d bytes recv from (%s) ", icmp_len, buf );
	prn_icmp( icmp, icmp_len );

	return 0;
}

// ping Request 보내기
int send_ping() 
{
	//gettimeofday( &atime, NULL );
	//diff1 = ( ( atime.tv_sec % 100 ) * 1000 ) + ( atime.tv_usec / 1000 );

	clock_gettime( CLOCK_REALTIME, &ts );

	diff1 = ( ( ts.tv_sec % 100 ) * 1000000 ) + ( ts.tv_nsec / 1000 );
	struct icmphdr* icmp;
	int             len, sendsize;
	icmp = (struct icmphdr *)sendbuf;
	bzero( (char *)icmp, sizeof(struct icmp) );

	icmp->code             = 0 ;
	icmp->type             = ICMP_ECHO; // ICMP_ECHO = 8
	icmp->un.echo.sequence = seqnum++;  // Ping 메시지 일련번호
	icmp->un.echo.id       = getpid();  // pid 를 ID로 설정
	icmp->checksum         = 0;         // checksum 계산전 반드시 zero
	icmp->checksum         = in_cksum( ( unsigned short *)icmp, sizeof( struct icmp ) );

	len = sizeof(struct icmphdr);  // 8 byte
	sendsize = sendto( rawsock, sendbuf, len, MSG_DONTWAIT, (struct sockaddr*)&sendaddr, sizeof( struct sockaddr ) );

	prn_icmp( icmp, sendsize ); // ICMP 헤더 출력

	return sendsize;
}

// checksum 구하기
unsigned short in_cksum( unsigned short *addr, int len ) 
{
	int            nleft  = len;
	int            sum    = 0;
	unsigned short *w     = addr;
	unsigned short answer = 0;

	while( nleft > 1 ) 
	{
		sum += *w++; nleft -= 2;
	}

	if( nleft == -1 ) 
	{
		*(unsigned char *)(&answer) = *(unsigned char *)w;
		sum += answer;
	}
	sum  = ( sum >> 16 ) + (sum & 0xffff);
	sum += ( sum >> 16 );
	answer = ~sum;

	return (answer);
}
