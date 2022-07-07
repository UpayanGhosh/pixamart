import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';


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
  late AnimationController _animationController;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }

  unFocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    toggle = 0;
    if(widget.textController.text.isNotEmpty){
      Navigator.pushNamed(context, '/search', arguments: {'searchQuery': widget.searchQuery});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 16.73,
      alignment: widget.rtl ? Alignment.centerRight : const Alignment(-1.0, 0.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDurationInMilli),
        height: MediaQuery.of(context).size.height / 16.73,
        width: (toggle == 0) ? MediaQuery.of(context).size.width / 8.16 : widget.width,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
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
              top: 3,
              right: 8,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: AnimatedBuilder(
                    builder: (context, widget) {
                      return Transform.rotate(
                        angle: _animationController.value * 2.0 * pi,
                        child: widget,
                      );
                    },
                    animation: _animationController,
                    child: GestureDetector(
                      onTap: () {
                        try {
                          widget.onSuffixTap();
                          if (widget.closeSearchOnSuffixTap) {
                            unFocusKeyboard();
                            setState(() {
                              toggle = 0;
                            });
                          }
                        } catch (e) {
                          throw e.toString();
                        }
                      },
                      child: GestureDetector(
                        child: Lottie.asset('assets/lottie/lf30_editor_in1ne4w9.json',
                        height: MediaQuery.of(context).size.height / 20,
                        width: MediaQuery.of(context).size.height / 20,
                        fit: BoxFit.fill),
                        onTap: (){
                          unFocusKeyboard();
                          },
                        ),
                    ),
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
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.topCenter,
                  width: widget.width / 1.7,
                  child: TextField(
                    controller: widget.textController,
                    inputFormatters: widget.inputFormatters,
                    focusNode: focusNode,
                    cursorRadius: const Radius.circular(10.0),
                    cursorWidth: 2.0,
                    onEditingComplete: () {
                      unFocusKeyboard();
                      setState(() {
                        toggle = 0;
                      });
                    },
                    style: widget.style ?? const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(bottom: 5),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: widget.helpText,
                      labelStyle: TextStyle(
                        color: const Color(0xff5B5B5B),
                        fontSize: MediaQuery.of(context).size.height / 50.2,
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
                    ? const Icon(Icons.arrow_back_ios)
                    : widget.prefixIcon!
                    : GestureDetector(
                  child: toggle == 1 ? Transform.rotate(angle: 0.8, child: const Icon(Icons.add)): Lottie.asset('assets/lottie/lf30_editor_in1ne4w9.json',),
                  onTap: (){
                    if(widget.textController.text.isNotEmpty && toggle == 1) {
                      widget.textController.clear();
                    }
                    else {
                      setState(() {
                        if (toggle == 0) {
                          toggle = 1;
                          setState(() {
                            if (widget.autoFocus) {
                              FocusScope.of(context).requestFocus(focusNode);
                            }
                          });
                          _animationController.forward();
                        }

                        else {
                          toggle = 0;
                          setState(() {
                            if (widget.autoFocus) unFocusKeyboard();
                          });
                          _animationController.reverse();
                        }
                      },
                      );
                    }
                  },
                ),
                onPressed: () {
                  if(widget.textController.text.isNotEmpty && toggle == 1) {
                    widget.textController.clear();
                  }
                  else {
                    setState(() {
                      if (toggle == 0) {
                        toggle = 1;
                        setState(() {
                          if (widget.autoFocus) {
                            FocusScope.of(context).requestFocus(focusNode);
                          }
                        });
                        _animationController.forward();
                      }

                      else {
                        toggle = 0;
                        setState(() {
                          if (widget.autoFocus) unFocusKeyboard();
                        });
                        _animationController.reverse();
                      }
                    },
                  );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
