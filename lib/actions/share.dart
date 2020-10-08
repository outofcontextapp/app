import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

void shareQuote({@required BuildContext context, @required Quote quote}) {
  if (kIsWeb) {
    shareQuoteTwitter(quote: quote);
    return;
  }

  shareQuoteFromMobile(quote: quote, context: context);
}

/// Sahre the target quote to twitter.
Future shareQuoteTwitter({Quote quote}) async {
  final quoteName = quote.name;
  final authorName = quote.author?.name ?? '';
  final referenceName = quote.mainReference?.name ?? '';

  String sharingText = quoteName;

  if (authorName.isNotEmpty) {
    sharingText += ' — $authorName';
  }

  if (referenceName != null && referenceName.length > 0) {
    sharingText += ' — $referenceName';
  }

  final hashtags = '&hashtags=outofcontext';

  final url =
      'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags';
  await launch(url);
}

void shareQuoteFromMobile({BuildContext context, Quote quote}) {
  final RenderBox box = context.findRenderObject();
  final quoteName = quote.name;
  final authorName = quote.author?.name ?? '';
  final referenceName = quote.mainReference?.name ?? '';

  String sharingText = quoteName;

  if (authorName != null && authorName.length > 0) {
    sharingText += ' — $authorName';
  }

  if (referenceName != null && referenceName.length > 0) {
    sharingText += ' — $referenceName';
  }

  Share.share(
    sharingText,
    subject: 'Out Of Context',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}

void shareReference(
    {@required BuildContext context, @required Reference reference}) {
  if (kIsWeb) {
    shareReferenceWeb(context: context, reference: reference);
    return;
  }

  shareReferenceMobile(context: context, reference: reference);
}

void shareReferenceWeb(
    {@required BuildContext context, @required Reference reference}) async {
  String sharingText = reference.name;
  final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

  if (reference.type.primary.isNotEmpty) {
    sharingText += ' (${reference.type.primary})';
  }

  final hashtags = '&hashtags=outofcontext';

  await launch(
    'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags&url=$urlReference',
  );
}

void shareReferenceMobile(
    {@required BuildContext context, @required Reference reference}) {
  final RenderBox box = context.findRenderObject();
  String sharingText = reference.name;
  final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

  if (reference.type.primary.isNotEmpty) {
    sharingText += ' (${reference.type.primary})';
  }

  sharingText += ' - URL: $urlReference';

  Share.share(
    sharingText,
    subject: 'Out Of Context',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}
