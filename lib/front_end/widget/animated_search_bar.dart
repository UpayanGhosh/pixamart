import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AnimatedSearchBar extends StatefulWidget {
  final double width;
  final TextEditingController searchQuery;
  final TextEditingController textController;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final String helpText;
  final int animationDurationInMilli;
  final onSuffixTap;
  final bool rtl;
  final bool autoFocus;
  final TextStyle? style;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final List<TextInputFormatter>? inputFormatters;

  const AnimatedSearchBar({
    Key? key,
    required this.width,
    required this.searchQuery,
    required this.textController,
    this.suffixIcon,
    this.prefixIcon,
    this.helpText = "Search...",

    this.color = Colors.white,

    required this.onSuffixTap,
    this.animationDurationInMilli = 375,

    this.rtl = false,

    this.autoFocus = false,

    this.style,

    this.closeSearchOnSuffixTap = false,

    this.inputFormatters,
  }) : super(key: key);

  @override
  AnimatedSearchBarState createState() => AnimatedSearchBarState();
}

int toggle = 0;

class AnimatedSearchBarState extends State<AnimatedSearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _con;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _con = AnimationController(
      vsync: this,

      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }

  unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      alignment: widget.rtl ? Alignment.centerRight : Alignment(-1.0, 0.0),

      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDurationInMilli),
        height: 48.0,
        width: (toggle == 0) ? 48.0 : widget.width,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: -10.0,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              top: 6.0,
              right: 7.0,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: AnimatedBuilder(
                    child: GestureDetector(
                      onTap: () {
                        try {
                          widget.onSuffixTap();

                          if (widget.closeSearchOnSuffixTap) {
                            unfocusKeyboard();
                            setState(() {
                              toggle = 0;
                            });
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: widget.suffixIcon != null
                          ? widget.suffixIcon
                          :
                        GestureDetector(
                          child: Icon(Icons.search_rounded,
                            size: 20.0),
                          onTap: (){
                            Navigator.pushNamed(context, '/search', arguments: {'searchQuery': widget.searchQuery});
                          },
                        ),
                    ),
                    builder: (context, widget) {
                      return Transform.rotate(
                        angle: _con.value * 2.0 * pi,
                        child: widget,
                      );
                    },
                    animation: _con,
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              left: (toggle == 0) ? 20.0 : 40.0,
              curve: Curves.easeOut,
              top: 11.0,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.topCenter,
                  width: widget.width / 1.7,
                  child: TextField(
                    controller: widget.textController,
                    inputFormatters: widget.inputFormatters,
                    focusNode: focusNode,
                    cursorRadius: Radius.circular(10.0),
                    cursorWidth: 2.0,
                    onEditingComplete: () {
                      unfocusKeyboard();
                      setState(() {
                        toggle = 0;
                      });
                    },
                    style: widget.style != null ? widget.style : TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(bottom: 5),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: widget.helpText,
                      labelStyle: TextStyle(
                        color: Color(0xff5B5B5B),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Material(
              color: widget.color,
              borderRadius: BorderRadius.circular(30.0),
              child: IconButton(
                splashRadius: 19.0,
                icon: widget.prefixIcon != null
                    ? toggle == 1
                    ? Icon(Icons.arrow_back_ios)
                    : widget.prefixIcon!
                    : Icon(
                  toggle == 1 ? Icons.arrow_back_ios : Icons.search,
                  size: 20.0,
                ),
                onPressed: () {
                  setState(
                        () {
                      if (toggle == 0) {
                        toggle = 1;
                        setState(() {
                          if (widget.autoFocus)
                            FocusScope.of(context).requestFocus(focusNode);
                        });

                        _con.forward();
                      } else {
                        toggle = 0;
                        setState(() {
                          if (widget.autoFocus) unfocusKeyboard();
                        });
                        _con.reverse();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
