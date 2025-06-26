import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCommentsPage extends StatefulWidget {
  final int productId;
  final String productName;

  const ProductCommentsPage({
    Key? key,
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  State<ProductCommentsPage> createState() => _ProductCommentsPageState();
}

class _ProductCommentsPageState extends State<ProductCommentsPage> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';

  double _averageRating = 0.0;
  int _reviewCount = 0;

  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0.0;

  String? _currentUserId;
  Map<String, String> _userNames = {};
  Set<String> _fetchingUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchProductReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getString('userId');
      });
    }
  }

  Future<void> _fetchProductReviews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http
          .get(
            Uri.parse('$API_BASE_URL/api/Review/product/${widget.productId}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> reviewJsonList = json.decode(response.body);
        if (mounted) {
          setState(() {
            _reviews =
                reviewJsonList.map((json) => Review.fromJson(json)).toList();
            _calculateReviewStats();
            _isLoading = false;
          });
          _fetchUsernamesForReviews();
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load reviews: ${response.statusCode}';
            _isLoading = false;
          });
        }
        print(
          'Reviews fetch failed: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Reviews request timed out: $e';
          _isLoading = false;
        });
      }
      print('Timeout fetching reviews: $e');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching reviews: $e';
          _isLoading = false;
        });
      }
      print('Network error fetching reviews: $e');
    }
  }

  Future<void> _fetchUsernamesForReviews() async {
    if (!mounted) return;

    Set<String> uniqueUserIds = {};
    for (var review in _reviews) {
      if (review.userId != null &&
          !_userNames.containsKey(review.userId) &&
          !_fetchingUserIds.contains(review.userId)) {
        uniqueUserIds.add(review.userId!);
      }
    }

    if (uniqueUserIds.isEmpty) {
      return;
    }

    setState(() {
      _fetchingUserIds.addAll(uniqueUserIds);
    });

    List<Future<void>> fetchTasks = [];
    for (String userId in uniqueUserIds) {
      fetchTasks.add(_fetchUsername(userId));
    }

    await Future.wait(fetchTasks);

    if (mounted) {
      setState(() {
        _fetchingUserIds.removeAll(uniqueUserIds);
      });
    }
  }

  Future<void> _fetchUsername(String userId) async {
    try {
      final uri = Uri.parse('$API_BASE_URL/api/Auth/username/$userId');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> usernameJson = json.decode(response.body);
        if (mounted) {
          setState(() {
            _userNames[userId] = usernameJson['userName'];
          });
        }
      } else {
        print(
          'Failed to load username for $userId: Status code ${response.statusCode}. Body: ${response.body}',
        );
        if (mounted) {
          setState(() {
            _userNames[userId] = 'Error: ${response.statusCode}';
          });
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout fetching username for $userId: $e');
      if (mounted) {
        setState(() {
          _userNames[userId] = 'Timeout';
        });
      }
    } catch (e) {
      print('Error fetching username for $userId: $e');
      if (mounted) {
        setState(() {
          _userNames[userId] = 'Error';
        });
      }
    }
  }

  void _calculateReviewStats() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _reviewCount = 0;
      return;
    }

    double totalRating = 0;
    for (var review in _reviews) {
      totalRating += review.rating.toDouble();
    }
    _averageRating = totalRating / _reviews.length;
    _reviewCount = _reviews.length;
  }

  Future<void> _submitReview() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to leave a review.'),
        ),
      );
      return;
    }

    if (_userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      print('Auth Token not found. Review could not be sent.');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Authentication error.')));
      }
      return;
    }
    final String apiUrl = '$API_BASE_URL/api/Review';

    final Map<String, dynamic> reviewData = {
      'userId': _currentUserId,
      'productId': widget.productId,
      'rating': _userRating.toInt(),
      'comment': _commentController.text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(reviewData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your review has been sent successfully!'),
            ),
          );
          _commentController.clear();
          setState(() {
            _userRating = 0.0;
          });
          _fetchProductReviews();
          Navigator.pop(context, true);
        }
      } else {
        print(
          'Review submission failed: ${response.statusCode} - ${response.body}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review.')),
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout during review submission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred during review submission (Timeout).',
            ),
          ),
        );
      }
    } catch (e) {
      print('Network error during review submission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred during review submission.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Reviews",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: ColorPalette.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: ColorPalette.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body:
            _isLoading
                ? Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: ColorPalette.primary,
                    size: height * 0.05,
                  ),
                )
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Rating:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingBar.builder(
                              itemSize: 24,
                              initialRating: _averageRating,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              itemBuilder:
                                  (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              onRatingUpdate: (rating) {},
                              ignoreGestures: true,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_averageRating.toStringAsFixed(1)} out of 5 (${_reviewCount} reviews)',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Write a Review:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RatingBar.builder(
                          itemSize: 30,
                          initialRating: _userRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                          ),
                          itemBuilder:
                              (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _userRating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Your comments...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: ColorPalette.cardColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Submit Review',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        _reviews.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No reviews yet. Be the first to review!',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                final String reviewerName =
                                    review.userId != null
                                        ? (_userNames[review.userId] ??
                                            (_fetchingUserIds.contains(
                                                  review.userId,
                                                )
                                                ? 'Loading...'
                                                : 'Anonymous'))
                                        : 'Anonymous';
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reviewerName,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        RatingBar.builder(
                                          itemSize: 18,
                                          initialRating:
                                              review.rating.toDouble(),
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 1.0,
                                              ),
                                          itemBuilder:
                                              (context, _) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                          onRatingUpdate: (rating) {},
                                          ignoreGestures: true,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review.comment,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            '${review.createdAt.toLocal().day}/${review.createdAt.toLocal().month}/${review.createdAt.toLocal().year}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
