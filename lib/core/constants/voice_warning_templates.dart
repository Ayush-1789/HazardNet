/// Warning message templates for voice assistant in multiple Indian languages
class VoiceWarningTemplates {
  /// Get warning message for hazard proximity
  /// [hazardType] - Type of hazard (pothole, speed_breaker, etc.)
  /// [distance] - Distance to hazard in meters
  /// [languageCode] - Language code (hi, ta, te, etc.)
  static String getProximityWarning({
    required String hazardType,
    required int distance,
    required String languageCode,
  }) {
    final templates = _warningTemplates[languageCode] ?? _warningTemplates['en']!;
    final hazardName = _getHazardName(hazardType, languageCode);
    
    if (distance > 400) {
      return templates['far']!.replaceAll('{hazard}', hazardName).replaceAll('{distance}', distance.toString());
    } else if (distance > 200) {
      return templates['medium']!.replaceAll('{hazard}', hazardName).replaceAll('{distance}', distance.toString());
    } else if (distance > 50) {
      return templates['near']!.replaceAll('{hazard}', hazardName).replaceAll('{distance}', distance.toString());
    } else {
      return templates['immediate']!.replaceAll('{hazard}', hazardName);
    }
  }
  
  /// Get hazard type name in specific language
  static String _getHazardName(String hazardType, String languageCode) {
    final hazardNames = _hazardTypeNames[languageCode] ?? _hazardTypeNames['en']!;
    return hazardNames[hazardType] ?? hazardNames['pothole']!;
  }
  
  // Warning templates for different distances and languages
  static const Map<String, Map<String, String>> _warningTemplates = {
    'en': {
      'far': 'Caution! {hazard} ahead in {distance} meters',
      'medium': 'Warning! {hazard} in {distance} meters. Please slow down',
      'near': 'Attention! {hazard} very close, {distance} meters ahead',
      'immediate': 'Alert! {hazard} right ahead. Be careful',
    },
    'hi': {
      'far': 'सावधान! {distance} मीटर आगे {hazard} है',
      'medium': 'चेतावनी! {distance} मीटर में {hazard}। कृपया धीमे चलें',
      'near': 'ध्यान दें! {hazard} बहुत पास है, {distance} मीटर आगे',
      'immediate': 'सतर्क रहें! {hazard} बिल्कुल आगे है। सावधान रहें',
    },
    'ta': {
      'far': 'எச்சரிக்கை! {distance} மீட்டர் முன்னால் {hazard} உள்ளது',
      'medium': 'எச்சரிக்கை! {distance} மீட்டரில் {hazard}. தயவுசெய்து வேகத்தைக் குறைக்கவும்',
      'near': 'கவனம்! {hazard} மிக அருகில் உள்ளது, {distance} மீட்டர் முன்னால்',
      'immediate': 'எச்சரிக்கை! {hazard} நேராக முன்னால் உள்ளது. கவனமாக இருங்கள்',
    },
    'te': {
      'far': 'జాగ్రత్త! {distance} మీటర్ల ముందు {hazard} ఉంది',
      'medium': 'హెచ్చరిక! {distance} మీటర్లలో {hazard}. దయచేసి నెమ్మదిగా వెళ్ళండి',
      'near': 'శ్రద్ధ! {hazard} చాలా దగ్గరగా ఉంది, {distance} మీటర్ల ముందు',
      'immediate': 'హెచ్చరిక! {hazard} సరిగ్గా ముందు ఉంది. జాగ్రత్తగా ఉండండి',
    },
    'bn': {
      'far': 'সতর্কতা! {distance} মিটার সামনে {hazard} আছে',
      'medium': 'সতর্কবার্তা! {distance} মিটারে {hazard}। অনুগ্রহ করে গতি কমান',
      'near': 'মনোযোগ! {hazard} খুব কাছে, {distance} মিটার সামনে',
      'immediate': 'সতর্ক! {hazard} ঠিক সামনে। সাবধান থাকুন',
    },
    'mr': {
      'far': 'सावधान! {distance} मीटर पुढे {hazard} आहे',
      'medium': 'इशारा! {distance} मीटरमध्ये {hazard}. कृपया हळू चला',
      'near': 'लक्ष द्या! {hazard} अगदी जवळ आहे, {distance} मीटर पुढे',
      'immediate': 'सावधान! {hazard} अगदी पुढे आहे. सावध राहा',
    },
    'gu': {
      'far': 'સાવધાન! {distance} મીટર આગળ {hazard} છે',
      'medium': 'ચેતવણી! {distance} મીટરમાં {hazard}. કૃપા કરીને ધીમે ચલાવો',
      'near': 'ધ્યાન આપો! {hazard} ખૂબ નજીક છે, {distance} મીટર આગળ',
      'immediate': 'સાવધાન! {hazard} સીધું આગળ છે. સાવધાન રહો',
    },
    'kn': {
      'far': 'ಎಚ್ಚರಿಕೆ! {distance} ಮೀಟರ್ ಮುಂದೆ {hazard} ಇದೆ',
      'medium': 'ಎಚ್ಚರಿಕೆ! {distance} ಮೀಟರ್‌ನಲ್ಲಿ {hazard}. ದಯವಿಟ್ಟು ನಿಧಾನವಾಗಿ ಹೋಗಿ',
      'near': 'ಗಮನ! {hazard} ತುಂಬಾ ಹತ್ತಿರದಲ್ಲಿದೆ, {distance} ಮೀಟರ್ ಮುಂದೆ',
      'immediate': 'ಎಚ್ಚರಿಕೆ! {hazard} ನೇರವಾಗಿ ಮುಂದೆ ಇದೆ. ಜಾಗರೂಕರಾಗಿರಿ',
    },
    'ml': {
      'far': 'ജാഗ്രത! {distance} മീറ്റർ മുന്നിൽ {hazard} ഉണ്ട്',
      'medium': 'മുന്നറിയിപ്പ്! {distance} മീറ്ററിൽ {hazard}. ദയവായി വേഗത കുറയ്ക്കുക',
      'near': 'ശ്രദ്ധിക്കുക! {hazard} വളരെ അടുത്താണ്, {distance} മീറ്റർ മുന്നിൽ',
      'immediate': 'മുന്നറിയിപ്പ്! {hazard} നേരെ മുന്നിലാണ്. ശ്രദ്ധിക്കുക',
    },
    'pa': {
      'far': 'ਸਾਵਧਾਨ! {distance} ਮੀਟਰ ਅੱਗੇ {hazard} ਹੈ',
      'medium': 'ਚੇਤਾਵਨੀ! {distance} ਮੀਟਰ ਵਿੱਚ {hazard}। ਕਿਰਪਾ ਕਰਕੇ ਹੌਲੀ ਚੱਲੋ',
      'near': 'ਧਿਆਨ ਦਿਓ! {hazard} ਬਹੁਤ ਨੇੜੇ ਹੈ, {distance} ਮੀਟਰ ਅੱਗੇ',
      'immediate': 'ਚੇਤਾਵਨੀ! {hazard} ਬਿਲਕੁਲ ਅੱਗੇ ਹੈ। ਸਾਵਧਾਨ ਰਹੋ',
    },
    'ur': {
      'far': 'خبردار! {distance} میٹر آگے {hazard} ہے',
      'medium': 'انتباہ! {distance} میٹر میں {hazard}۔ براہ کرم آہستہ چلائیں',
      'near': 'توجہ! {hazard} بہت قریب ہے، {distance} میٹر آگے',
      'immediate': 'خبردار! {hazard} بالکل آگے ہے۔ محتاط رہیں',
    },
  };
  
  // Hazard type names in different languages
  static const Map<String, Map<String, String>> _hazardTypeNames = {
    'en': {
      'pothole': 'pothole',
      'speed_breaker': 'speed breaker',
      'speed_breaker_unmarked': 'unmarked speed breaker',
      'obstacle': 'obstacle',
      'closed_road': 'closed road',
      'lane_blocked': 'blocked lane',
    },
    'hi': {
      'pothole': 'गड्ढा',
      'speed_breaker': 'स्पीड ब्रेकर',
      'speed_breaker_unmarked': 'बिना निशान वाला स्पीड ब्रेकर',
      'obstacle': 'बाधा',
      'closed_road': 'बंद सड़क',
      'lane_blocked': 'अवरुद्ध लेन',
    },
    'ta': {
      'pothole': 'குழி',
      'speed_breaker': 'வேக தடை',
      'speed_breaker_unmarked': 'குறியிடப்படாத வேக தடை',
      'obstacle': 'தடை',
      'closed_road': 'மூடப்பட்ட சாலை',
      'lane_blocked': 'தடுக்கப்பட்ட பாதை',
    },
    'te': {
      'pothole': 'గొయ్యి',
      'speed_breaker': 'స్పీడ్ బ్రేకర్',
      'speed_breaker_unmarked': 'గుర్తు లేని స్పీడ్ బ్రేకర్',
      'obstacle': 'అడ్డంకి',
      'closed_road': 'మూసివేసిన రహదారి',
      'lane_blocked': 'నిరోధించబడిన లేన్',
    },
    'bn': {
      'pothole': 'গর্ত',
      'speed_breaker': 'স্পিড ব্রেকার',
      'speed_breaker_unmarked': 'চিহ্নহীন স্পিড ব্রেকার',
      'obstacle': 'বাধা',
      'closed_road': 'বন্ধ রাস্তা',
      'lane_blocked': 'অবরুদ্ধ লেন',
    },
    'mr': {
      'pothole': 'खड्डा',
      'speed_breaker': 'स्पीड ब्रेकर',
      'speed_breaker_unmarked': 'चिन्ह नसलेला स्पीड ब्रेकर',
      'obstacle': 'अडथळा',
      'closed_road': 'बंद रस्ता',
      'lane_blocked': 'अवरोधित लेन',
    },
    'gu': {
      'pothole': 'ખાડો',
      'speed_breaker': 'સ્પીડ બ્રેકર',
      'speed_breaker_unmarked': 'ચિહ્નિત ન થયેલ સ્પીડ બ્રેકર',
      'obstacle': 'અવરોધ',
      'closed_road': 'બંધ રસ્તો',
      'lane_blocked': 'અવરોધિત લેન',
    },
    'kn': {
      'pothole': 'ಹಳ್ಳ',
      'speed_breaker': 'ಸ್ಪೀಡ್ ಬ್ರೇಕರ್',
      'speed_breaker_unmarked': 'ಗುರುತು ಹಾಕದ ಸ್ಪೀಡ್ ಬ್ರೇಕರ್',
      'obstacle': 'ಅಡಚಣೆ',
      'closed_road': 'ಮುಚ್ಚಿದ ರಸ್ತೆ',
      'lane_blocked': 'ತಡೆಯಲಾದ ಲೇನ್',
    },
    'ml': {
      'pothole': 'കുഴി',
      'speed_breaker': 'സ്പീഡ് ബ്രേക്കർ',
      'speed_breaker_unmarked': 'അടയാളപ്പെടുത്താത്ത സ്പീഡ് ബ്രേക്കർ',
      'obstacle': 'തടസ്സം',
      'closed_road': 'അടച്ച റോഡ്',
      'lane_blocked': 'തടഞ്ഞ പാത',
    },
    'pa': {
      'pothole': 'ਟੋਆ',
      'speed_breaker': 'ਸਪੀਡ ਬ੍ਰੇਕਰ',
      'speed_breaker_unmarked': 'ਬਿਨਾਂ ਨਿਸ਼ਾਨ ਵਾਲਾ ਸਪੀਡ ਬ੍ਰੇਕਰ',
      'obstacle': 'ਰੁਕਾਵਟ',
      'closed_road': 'ਬੰਦ ਸੜਕ',
      'lane_blocked': 'ਰੁਕੀ ਹੋਈ ਲੇਨ',
    },
    'ur': {
      'pothole': 'گڑھا',
      'speed_breaker': 'سپیڈ بریکر',
      'speed_breaker_unmarked': 'بغیر نشان والا سپیڈ بریکر',
      'obstacle': 'رکاوٹ',
      'closed_road': 'بند سڑک',
      'lane_blocked': 'مسدود لین',
    },
  };
}
