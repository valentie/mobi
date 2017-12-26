
#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD false
#endif



#define SYSTEM_VERSION   [[UIDevice currentDevice] systemVersion]
#define SYSTEM_MODEL     [[UIDevice currentDevice] model]
#define SYSTEM_BRAND     @"Apple"



#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


typedef enum {
  DataItemNone,
  DataItemCategories
} DataItem;

#define INAPPSHAREDSECRET @"9417ab2070a645d3bfe72b7ba73df109"


#define KEYCHAINCODE @"MobiTelevisionLoginDataKeychain"

#define PAYPAL_SANDBOXID @"ASTDxNoxJlqHC9flylqaEFtxfv9JfLKN1QjxlDTw4Y7kn01aDy6F5HACfitN8CmAVG4rtfzTjK4P1ZW4"
#define PAYPAL_PRODUCTIONID @"AS8f1wv4TxeQwMXOkOuIEperPsUr_QwI6GL-5i04AVLeV-nSvG7SnVZi61bTKlin0FNejkcA-UzS94q6"


//#define API_HOST @"104.236.5.233/index.php"
#define API_HOST @"www.mobitelevision.tv"

#define API_SHAREURL @"http://www.mobitelevision.tv/app/deeplink/"
#define API_END_POINT @"api/service/format/json/request/"
#define API_IMAGE_HOST @"http://www.mobitelevision.tv/assets/content/"
/*
 
 #define API_HOST @"www.mind-zone.net"
 #define API_SHAREURL @"http://ww.mind-zone.net/app/deeplink/"
 #define API_END_POINT @"projects/mobitelevision/index.php/api/service/format/json/request/"
 #define API_IMAGE_HOST @"http://ww.mind-zone.net/projects/mobitelevision/assets/content/"
 */


#define MAXWIDTHMASTERVIEW (IS_IPAD ? 320 : 280)
#define KEYBOARDHEIGHT (IS_IPAD ? 352 : 216)

#define FONTSIZE14 (IS_IPAD ? 10 : 10)
#define FONTSIZE16 (IS_IPAD ? 11 : 11)
#define FONTSIZE18 (IS_IPAD ? 12 : 12)
#define FONTSIZE21 (IS_IPAD ? 16 : 16)

