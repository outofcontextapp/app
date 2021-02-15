import 'package:auto_route/auto_route.dart';
import 'package:figstyle/components/user_lists.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/favourites.dart';
import 'package:figstyle/actions/quotes.dart';
import 'package:figstyle/actions/quotidians.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/quote_row.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class QuoteRowWithActions extends StatefulWidget {
  final bool canManage;
  final bool isConnected;

  /// If true, author will be displayed on card.
  /// Specify this only when [componentType] is equels to
  /// [ItemComponentType.card] or [ItemComponentType.verticalCard].
  final bool showAuthor;

  /// If true, this card will have a border of 2.0px
  /// of the quote's first topic color.
  /// Available only when [componentType] = [ItemComponentType.verticalCard].
  final bool showBorder;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  /// If true, the popup menu will be displayed whatever [useSwipeActions] value.
  final bool showPopupMenuButton;

  final Color color;

  /// Card's width if [componentType] equals [card].
  final double cardWidth;

  /// Card's height if [componentType] equals [card].
  final double cardHeight;

  /// Widget's elevation. If [null], the default value is 0.
  final double elevation;

  /// Quote's font size. If null, the default value is 20.0.
  final double quoteFontSize;

  final Function onAfterAddToFavourites;
  final Function(bool) onAfterDeletePubQuote;
  final Function onAfterRemoveFromFavourites;
  final Function onAfterRemoveFromList;
  final Function onBeforeAddToFavourites;
  final Function onBeforeDeletePubQuote;
  final Function onBeforeRemoveFromFavourites;
  final Function onBeforeRemoveFromList;
  final Function onRemoveFromList;

  final EdgeInsets padding;

  final ItemComponentType componentType;

  /// Maximum lines to display on the component
  /// when [componentType] equals [card] or [verticalCard].
  final int maxLines;

  /// Required if `useSwipeActions` is true.
  final Key key;

  final List<Widget> stackChildren;

  final TextOverflow overflow;

  final String pageRoute;

  final Quote quote;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;

  final QuotePageType quotePageType;

  /// A widget positioned before the main content (quote's content).
  /// Typcally an Icon or a small Container.
  final Widget leading;

  QuoteRowWithActions({
    this.canManage = false,
    this.cardWidth,
    this.cardHeight,
    this.color,
    this.componentType = ItemComponentType.row,
    this.elevation,
    this.isConnected = false,
    this.key,
    this.maxLines = 6,
    this.onAfterAddToFavourites,
    this.onAfterDeletePubQuote,
    this.onAfterRemoveFromFavourites,
    this.onAfterRemoveFromList,
    this.onBeforeAddToFavourites,
    this.onBeforeDeletePubQuote,
    this.onBeforeRemoveFromFavourites,
    this.onBeforeRemoveFromList,
    this.onRemoveFromList,
    this.overflow = TextOverflow.ellipsis,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.pageRoute = '',
    @required this.quote,
    this.quoteFontSize = 20.0,
    this.quoteId,
    this.quotePageType = QuotePageType.published,
    this.showAuthor = false,
    this.showBorder = false,
    this.showPopupMenuButton = false,
    this.stackChildren = const [],
    this.leading,
    this.useSwipeActions = false,
  });

  @override
  _QuoteRowWithActionsState createState() => _QuoteRowWithActionsState();
}

class _QuoteRowWithActionsState extends State<QuoteRowWithActions> {
  bool deleteAuthor = false;
  bool deleteReference = false;

  @override
  initState() {
    super.initState();
    fetchIsFav();
  }

  @override
  Widget build(BuildContext context) {
    List<PopupMenuEntry<String>> popupItems;
    Function itemBuilder;

    List<SwipeAction> leadingActions = defaultActions;
    List<SwipeAction> trailingActions = defaultActions;

    if (widget.useSwipeActions) {
      leadingActions = getLeadingActions();
      trailingActions = getTrailingActions();
    } else {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    if (widget.showPopupMenuButton && popupItems == null) {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    return QuoteRow(
      cardHeight: widget.cardHeight,
      cardWidth: widget.cardWidth,
      componentType: widget.componentType,
      quote: widget.quote,
      color: widget.color,
      elevation: widget.elevation,
      fetchIsFav: fetchIsFav,
      itemBuilder: itemBuilder,
      key: widget.key,
      leading: widget.leading,
      leadingActions: leadingActions,
      maxLines: widget.maxLines,
      onLongPress: onLongPress,
      onSelected: onSelected,
      overflow: widget.overflow,
      padding: widget.padding,
      quoteId: widget.quoteId,
      quoteFontSize: widget.quoteFontSize,
      showAuthor: widget.showAuthor,
      showBorder: widget.showBorder,
      stackChildren: widget.stackChildren,
      trailingActions: trailingActions,
      useSwipeActions: widget.useSwipeActions,
    );
  }

  void confirmAndDeletePubQuote() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, childSetState) {
            return Material(
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      dense: true,
                      title: Opacity(
                        opacity: 0.6,
                        child: Text("Delete associated author"),
                      ),
                      value: deleteAuthor,
                      onChanged: (isChecked) {
                        childSetState(() {
                          deleteAuthor = isChecked;
                        });
                      },
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Opacity(
                        opacity: 0.6,
                        child: Text("Delete associated reference"),
                      ),
                      value: deleteReference,
                      onChanged: (isChecked) {
                        childSetState(() {
                          deleteReference = isChecked;
                        });
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      tileColor: Color(0xfff55c5c),
                      onTap: () {
                        context.router.pop();
                        deletePubQuote();
                      },
                    ),
                    ListTile(
                      title: Text('Cancel'),
                      trailing: Icon(Icons.close),
                      onTap: context.router.pop,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void deletePubQuote() async {
    if (widget.onBeforeDeletePubQuote != null) {
      widget.onBeforeDeletePubQuote();
    }

    final success = await QuotesActions.delete(
      quote: widget.quote,
      deleteAuthor: deleteAuthor,
      deleteReference: deleteReference,
    );

    if (widget.onAfterDeletePubQuote != null) {
      widget.onAfterDeletePubQuote(success);
    }
  }

  Future fetchIsFav() async {
    if (!stateUser.isUserConnected) {
      return;
    }

    final isFav = await FavActions.isFav(
      quoteId: widget.quote.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      widget.quote.starred = isFav;
    });
  }

  List<PopupMenuEntry<String>> getPopupItems() {
    final popupItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'share',
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
        ),
      ),
    ];

    if (widget.quotePageType == QuotePageType.published && widget.isConnected) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'addtofavourites',
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Like'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    } else if (widget.quotePageType == QuotePageType.favourites) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'removefromfavourites',
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Remove from favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    } else if (widget.quotePageType == QuotePageType.list) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'addtofavourites',
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Add to favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    }

    if (widget.canManage) {
      popupItems.addAll([
        PopupMenuItem(
            value: 'addquotidian',
            child: ListTile(
              leading: Icon(Icons.wb_sunny),
              title: Text('Add to quotidians'),
            )),
        PopupMenuItem(
            value: 'deletequote',
            child: ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Delete published'),
            )),
      ]);
    }

    return popupItems;
  }

  List<SwipeAction> getLeadingActions() {
    final quote = widget.quote;

    final actions = [
      SwipeAction(
        title: 'Share',
        icon: Icon(Icons.ios_share, color: Colors.white),
        color: Colors.blue,
        onTap: (CompletionHandler handler) {
          handler(false);
          ShareActions.shareQuote(context: context, quote: quote);
        },
      ),
    ];

    if (widget.canManage) {
      actions.addAll([
        SwipeAction(
          title: 'Quotidian',
          icon: Icon(Icons.wb_sunny, color: Colors.white),
          color: Colors.yellow.shade800,
          onTap: (CompletionHandler handler) async {
            handler(false);
            await QuotidiansActions.add(
              quote: quote,
              lang: quote.lang,
            );
          },
        ),
        SwipeAction(
          title: 'Delete',
          icon: Icon(Icons.delete_outline, color: Colors.white),
          color: stateColors.deletion,
          onTap: (CompletionHandler handler) {
            handler(false);
            confirmAndDeletePubQuote();
          },
        ),
      ]);
    }

    return actions;
  }

  List<SwipeAction> getTrailingActions() {
    if (!widget.isConnected) {
      return defaultActions;
    }

    final actions = <SwipeAction>[];

    actions.add(
      SwipeAction(
        title: 'Add to...',
        icon: Icon(Icons.playlist_add, color: Colors.white),
        color: Color(0xff5cc9f5),
        onTap: (CompletionHandler handler) {
          handler(false);
          showBottomSheetList();
        },
      ),
    );

    if (widget.quotePageType == QuotePageType.favourites) {
      actions.insert(
        0,
        SwipeAction(
          title: 'Unlike',
          icon: Icon(Icons.favorite, color: Colors.white),
          color: Color(0xff6638f0),
          onTap: (CompletionHandler handler) {
            handler(false);
            toggleFavourite();
          },
        ),
      );
    } else {
      actions.insert(
        0,
        SwipeAction(
          title: widget.quote.starred ? 'Unlike' : 'Like',
          icon: widget.quote.starred
              ? Icon(Icons.favorite, color: Colors.white)
              : Icon(Icons.favorite_border, color: Colors.white),
          color: Color(0xff6638f0),
          onTap: (CompletionHandler handler) {
            handler(false);
            toggleFavourite();
          },
        ),
      );
    }

    if (widget.quotePageType == QuotePageType.list) {
      actions.add(SwipeAction(
        title: 'Remove',
        icon: Icon(Icons.remove_circle, color: Colors.white),
        color: Colors.pink,
        onTap: (CompletionHandler handler) {
          handler(false);
          widget.onRemoveFromList(widget.quote);
        },
      ));
    }

    return actions;
  }

  void onLongPress() {
    final children = [
      ListTile(
        title: Text('Share'),
        trailing: Icon(
          UniconsLine.share,
        ),
        onTap: () {
          context.router.pop();
          ShareActions.shareQuote(
            context: context,
            quote: widget.quote,
          );
        },
      ),
    ];

    if (widget.isConnected) {
      children.addAll([
        ListTile(
          title: Text('Add to...'),
          trailing: Icon(
            UniconsLine.book_medical,
          ),
          onTap: () {
            context.router.pop();

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              showBottomSheetList();
            });
          },
        ),
        ListTile(
          title: widget.quote.starred ? Text('Unlike') : Text('Like'),
          trailing: widget.quote.starred
              ? Icon(UniconsLine.heart_break)
              : Icon(UniconsLine.heart),
          onTap: () {
            context.router.pop();
            toggleFavourite();
          },
        ),
      ]);
    }

    if (widget.canManage) {
      children.addAll([
        ListTile(
          title: Text('Delete'),
          trailing: Icon(
            UniconsLine.trash,
          ),
          onTap: () {
            context.router.pop();
            confirmAndDeletePubQuote();
          },
        ),
        ListTile(
          title: Text('Next quotidian'),
          trailing: Icon(UniconsLine.sunset),
          onTap: () {
            context.router.pop();
            QuotidiansActions.add(
              quote: widget.quote,
              lang: widget.quote.lang,
            );
          },
        ),
      ]);
    }

    int flex =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth ? 5 : 1;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  void onSelected(value) async {
    final quote = widget.quote;

    switch (value) {
      case 'addtofavourites':
        if (widget.onBeforeAddToFavourites != null) {
          widget.onBeforeAddToFavourites();
        }

        final success = await FavActions.add(
          context: context,
          quote: quote,
        );

        if (widget.onAfterAddToFavourites != null) {
          widget.onAfterAddToFavourites(success);
        }

        break;
      case 'addtolist':
        showBottomSheetList();
        break;
      case 'removefromfavourites':
        if (widget.onBeforeRemoveFromFavourites != null) {
          widget.onBeforeRemoveFromFavourites();
        }

        final success = await FavActions.remove(
          context: context,
          quote: quote,
        );

        if (widget.onAfterRemoveFromFavourites != null) {
          widget.onAfterRemoveFromFavourites(success);
        }

        break;
      case 'removefromlist':
        widget.onRemoveFromList(quote);
        break;
      case 'share':
        ShareActions.shareQuote(
          context: context,
          quote: quote,
        );
        break;
      case 'addquotidian':
        QuotidiansActions.add(
          quote: quote,
          lang: quote.lang,
        );

        break;
      case 'deletequote':
        // Dialog for large screens layout.
        FlashHelper.simpleDialog(
          context,
          title: 'Confirm deletion?',
          message:
              'The published quote will be deleted. This action is irreversible.',
          negativeAction: (context, controller, setState) {
            return FlatButton(
              child: Text('NO'),
              onPressed: () => controller.dismiss(),
            );
          },
          positiveAction: (context, controller, setState) {
            return FlatButton(
              child: Text('DELETE'),
              onPressed: () {
                controller.dismiss();
                deletePubQuote();
              },
            );
          },
        );
        break;
      default:
    }
  }

  Future toggleFavourite() async {
    final quote = widget.quote;

    if (widget.quote.starred) {
      showSnack(
        context: context,
        title: "Favourites",
        type: SnackType.success,
        icon: Icon(UniconsLine.heart_break, color: Colors.pink),
        message: "This quote has been successfully unliked!",
      );

      setState(() {
        widget.quote.starred = false;
      });

      if (widget.onBeforeRemoveFromFavourites != null) {
        widget.onBeforeRemoveFromFavourites();
      }

      final success = await FavActions.remove(
        context: context,
        quote: quote,
      );

      if (!success) {
        setState(() {
          widget.quote.starred = true;
        });
      }

      if (widget.onAfterRemoveFromFavourites != null) {
        widget.onAfterRemoveFromFavourites(success);
      }
    } else {
      showSnack(
        context: context,
        title: "Favourites",
        type: SnackType.success,
        icon: Icon(UniconsLine.heart, color: Colors.pink),
        message: "This quote has been successfully liked!",
      );

      setState(() {
        widget.quote.starred = true;
      });

      if (widget.onBeforeAddToFavourites != null) {
        widget.onBeforeAddToFavourites();
      }

      final success = await FavActions.add(
        context: context,
        quote: quote,
      );

      if (!success) {
        setState(() {
          widget.quote.starred = false;
        });
      }

      if (widget.onAfterAddToFavourites != null) {
        widget.onAfterAddToFavourites(success);
      }
    }
  }

  void showBottomSheetList() {
    if (!stateUser.isUserConnected) {
      showSnack(
        context: context,
        message: "You must sign in to add this quote to a list.",
        type: SnackType.error,
      );

      return;
    }

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => UserLists(
        scrollController: ModalScrollController.of(context),
        quote: widget.quote,
      ),
    );
  }
}
