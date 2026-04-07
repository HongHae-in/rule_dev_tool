class CaptchaType {
  static const int imageCaptcha = 0;
  static const int autoClickButton = 1;
}

class AntiCrawlerConfig {
  final bool enabled;
  final int captchaType;
  final String captchaImage;
  final String captchaInput;
  final String captchaButton;

  AntiCrawlerConfig({
    required this.enabled,
    required this.captchaType,
    required this.captchaImage,
    required this.captchaInput,
    required this.captchaButton,
  });

  factory AntiCrawlerConfig.empty() {
    return AntiCrawlerConfig(
      enabled: false,
      captchaType: CaptchaType.imageCaptcha,
      captchaImage: '',
      captchaInput: '',
      captchaButton: '',
    );
  }

  factory AntiCrawlerConfig.fromJson(Map<String, dynamic> json) {
    return AntiCrawlerConfig(
      enabled: json['enabled'] ?? false,
      captchaType: json['captchaType'] ?? CaptchaType.imageCaptcha,
      captchaImage: json['captchaImage'] ?? '',
      captchaInput: json['captchaInput'] ?? '',
      captchaButton: json['captchaButton'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'captchaType': captchaType,
      'captchaImage': captchaImage,
      'captchaInput': captchaInput,
      'captchaButton': captchaButton,
    };
  }
}
