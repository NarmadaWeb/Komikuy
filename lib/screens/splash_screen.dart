import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:komikuy/screens/main_screen.dart';
import 'package:komikuy/services/ad_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isTimerDone = false;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;
  bool _hasNavigated = false;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadAd();
  }

  void _startTimer() {
    // Minimum splash time
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
        _checkNavigation();
      }
    });

    // Maximum wait time (timeout) - 8 seconds total
    Timer(const Duration(seconds: 8), () {
      if (mounted && !_isAdLoaded && !_isAdFailed) {
         // If still waiting for ad, just go
         _navigateToMain();
      }
    });
  }

  void _loadAd() {
    AdService().loadRewardedAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
          _checkNavigation();
        }
      },
      onAdFailed: (error) {
        if (mounted) {
          setState(() {
            _isAdFailed = true;
          });
          _checkNavigation();
        }
      },
    );
  }

  void _checkNavigation() {
    // Only proceed if the minimum timer is done
    if (!_isTimerDone) return;

    if (_isAdLoaded && _rewardedAd != null) {
      AdService().showRewardedAd(_rewardedAd!, () {
        _navigateToMain();
      });
    } else if (_isAdFailed) {
      _navigateToMain();
    } else {
      // Ad is still loading after 3 seconds.
      // We can choose to wait (showing a spinner) or skip.
      // For better UX, let's wait a max of 2 more seconds, or just show a loading indicator.
      // Here, we'll just wait until it either loads or fails.
      // The UI will continue showing the splash logo.
    }
  }

  void _navigateToMain() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366), 
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
