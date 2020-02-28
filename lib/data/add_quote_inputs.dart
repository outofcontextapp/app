class AddQuoteInputs {
  /// Quote's id if this is an edit.
  static String id                  = '';
  static String name                = '';
  static String lang                = 'en';
  static List<String> topics        = [];

  /// Draft's quote id (filled when creating a new quote).
  static String draftId             = '';

  /// If not empty, the author already exists.
  static String authorAffiliateUrl  = '';
  static String authorId            = '';
  static String authorImgUrl        = '';
  static String authorName          = '';
  static String authorJob           = '';
  static String authorSummary       = '';
  static String authorUrl           = '';
  static String authorWikiUrl       = '';

  /// If not empty, the reference already exists.
  static String refAffiliateUrl     = '';
  static String refId               = '';
  static String refImgUrl           = '';
  static String refLang             = 'en';
  static String refName             = '';
  static String refSummary          = '';
  static String refPrimaryType      = '';
  static String refSecondaryType    = '';
  static String refUrl              = '';
  static String refWikiUrl          = '';

  static String comment             = '';
  static String region              = '';

  static bool isSending             = false;
  static bool isCompleted           = false;
  static bool hasExceptions         = false;
  static String exceptionMessage    = '';

  static void clearAll() {
    clearAuthor();
    clearComment();
    clearQuoteId();
    clearQuoteName();
    clearReference();
    clearStatus();
    clearTopics();
  }

  static void clearAuthor() {
    authorAffiliateUrl  = '';
    authorId            = '';
    authorImgUrl        = '';
    authorName          = '';
    authorJob           = '';
    authorSummary       = '';
    authorUrl           = '';
    authorWikiUrl       = '';
  }

  static void clearComment() {
    comment = '';
  }

  static void clearQuoteId() {
    id = '';
  }

  static void clearQuoteName() {
    name = '';
    lang = 'en';
    region = '';
  }

  static void clearReference() {
    refAffiliateUrl   = '';
    refId             = '';
    refImgUrl         = '';
    refLang           = 'en';
    refName           = '';
    refSummary        = '';
    refPrimaryType    = '';
    refSecondaryType  = '';
    refUrl            = '';
    refWikiUrl        = '';
  }

  static void clearStatus() {
    isCompleted = false;
    hasExceptions = false;
  }

  static void clearTopics() {
    topics.clear();
  }
}
