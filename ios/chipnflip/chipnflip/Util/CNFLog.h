#define __SFILE__					\
	(strrchr(__FILE__,'/')			\
	? strrchr(__FILE__,'/') + 1		\
	: __FILE__						\
)

#define CNFLog(fmt, ...)			\
	NSLog((@"%s:%d:%s" fmt), __SFILE__, __LINE__, __FUNCTION__, ##__VA_ARGS__)
