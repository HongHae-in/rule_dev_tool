import 'dart:convert';

class Utils {
  static String getRandomUA() {
    const userAgents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    ];
    return userAgents[(DateTime.now().millisecond) % userAgents.length];
  }

  static String getRandomAcceptedLanguage() {
    const languages = [
      'zh-CN,zh;q=0.9,en;q=0.8',
      'zh-CN,zh;q=0.9',
      'en-US,en;q=0.9,zh;q=0.8',
    ];
    return languages[(DateTime.now().millisecond) % languages.length];
  }

  static String jsonToKazumiBase64(String jsonStr) {
    String base64Str = base64Encode(utf8.encode(jsonStr));
    return 'kazumi://$base64Str';
  }

  static String kazumiBase64ToJson(String kazumiBase64Str) {
    if (!kazumiBase64Str.startsWith('kazumi://')) {
      return '';
    }
    String base64Str = kazumiBase64Str.substring(9);
    String jsonStr = utf8.decode(base64.decode(base64Str));
    return jsonStr;
  }
}
