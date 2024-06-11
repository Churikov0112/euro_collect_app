import 'dart:math' as math;

import 'package:flutter/material.dart';

class StickerPackScreen extends StatefulWidget {
  const StickerPackScreen({super.key});

  @override
  StickerPackScreenState createState() => StickerPackScreenState();
}

class StickerPackScreenState extends State<StickerPackScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;

  bool _showCards = false;

  final List<Widget> cardsList = [
    Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 23, 23),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 144, 56, 56),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 162, 135),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 255, 1),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 18, 130),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openPack() {
    setState(() {
      _showCards = true;
    });
    _controller.forward().whenComplete(() {});
  }

  void _removeCard(int i) {
    cardsList.removeLast();
    setState(() {});
    if (i == 0) {
      _closePack();
    }
  }

  void _closePack() {
    setState(() {
      _showCards = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          if (_showCards)
            for (int i = 0; i < cardsList.length; i++)
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) => Positioned(
                  right: 100,
                  left: 100,
                  top: 400 - _slideAnimation.value * 300,
                  child: Dismissible(
                    key: Key(i.toString()),
                    onDismissed: (direction) {
                      _removeCard(i);
                    },
                    child: cardsList[i],
                  ),
                ),
              ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) => Positioned(
              top: 100 + _slideAnimation.value * 100,
              child: SizedBox(
                width: mq.size.width,
                height: mq.size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) => Transform(
                        transform: Matrix4.identity()
                          ..rotateZ(_rotateAnimation.value * -1 * math.pi * 0.1), // Вращаем на 90 градусов

                        origin: const Offset(1.0, 1.0), // Правая нижняя точка
                        child: Container(
                          width: 200,
                          height: 30,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showCards ? _closePack : _openPack,
                      child: Container(
                        height: 300,
                        width: 200,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
