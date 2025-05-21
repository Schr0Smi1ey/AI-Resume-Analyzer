import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../services/history_service.dart';
import '../../model/analysis_model.dart';
import 'widgets/analysis_header.dart';
import 'widgets/score_card.dart';
import 'widgets/feedback_card.dart';
import 'widgets/keyword_feedback.dart';
import 'widgets/section_feedback_card.dart';
import 'widgets/feedback_list.dart';
import 'widgets/analysis_loading.dart';
import 'widgets/analysis_error.dart';

class ResumeAnalysisScreen extends StatefulWidget {
  static const routeName = '/resume-analysis';
  final Map<String, dynamic> args;
  final AnalysisModel? preloadedAnalysis;

  const ResumeAnalysisScreen({
    super.key,
    required this.args,
    this.preloadedAnalysis,
  });

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen>
    with TickerProviderStateMixin {
  late Future<AnalysisModel> _analysisFuture;
  late final TabController _tabController;
  late final AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();

    _analysisFuture =
        widget.preloadedAnalysis != null
            ? Future.value(widget.preloadedAnalysis)
            : _startAnalysis();
    _isInitialized = true;
  }

  Future<AnalysisModel> _startAnalysis() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      return await apiService.analyzeResume(
        extractedText: widget.args['extractedText'] ?? '',
        jobDescription: widget.args['jobDesc'] ?? '',
      );
    } catch (e) {
      debugPrint('Analysis error: $e');
      _showSnackBar('Failed to analyze resume: $e', isError: true);
      throw Exception('Failed to analyze resume: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final backgroundColor =
        isError
            ? Colors.red.withOpacity(0.8)
            : (isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50))
                .withOpacity(0.8);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fileName = widget.args['fileName'] ?? 'Resume Analysis';

    // Define theme-dependent colors
    final primaryColor = const Color(0xFF00C853);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.preloadedAnalysis != null ? 'Historical Analysis' : fileName,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: backgroundColor,
        actions: [
          if (widget.preloadedAnalysis == null)
            IconButton(
              icon: Icon(Icons.refresh, color: accentColor),
              onPressed: () {
                setState(() {
                  _analysisFuture = _startAnalysis();
                });
              },
            ),
        ],
        elevation: 2,
        shadowColor: Colors.black26,
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentColor,
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Scores'),
            Tab(text: 'Feedback'),
            Tab(text: 'Sections'),
            Tab(text: 'Confidence'),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _analysisFuture = _startAnalysis();
            });
          },
          backgroundColor: primaryColor,
          tooltip: 'Re-analyze',
          hoverColor: accentColor,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
      body: FutureBuilder<AnalysisModel>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder:
                (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
            child: _buildContent(context, snapshot, theme),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<AnalysisModel> snapshot,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final primaryColor = const Color(0xFF00C853);

    if (!_isInitialized) {
      return Container(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const AnalysisLoading();
    }

    if (snapshot.hasError) {
      return AnalysisError(
        message: snapshot.error.toString(),
        onRetry: () {
          setState(() {
            _analysisFuture = _startAnalysis();
          });
        },
      );
    }

    if (!snapshot.hasData) {
      return AnalysisError(
        message:
            'No analysis data available. Please re-analyze or upload a resume.',
        onRetry: () {
          setState(() {
            _analysisFuture = _startAnalysis();
          });
        },
      );
    }

    final analysis = snapshot.data!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preloadedAnalysis == null) {
        Provider.of<HistoryService>(
          context,
          listen: false,
        ).saveAnalysis(analysis);
      }
    });

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildScoresTab(analysis, theme),
        _buildFeedbackTab(analysis, theme),
        _buildSectionsTab(analysis, theme),
        _buildConfidenceTab(analysis, theme),
      ],
    );
  }

  Widget _buildScoresTab(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: FadeInUp(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        isDark
                            ? const Color(0xFF00E676).withOpacity(0.5)
                            : const Color(0xFF4CAF50).withOpacity(0.5),
                  ),
                ),
                child: AnalysisHeader(analysis: analysis),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildScoresChart(analysis, theme),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildScoresSection(analysis, theme),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildScoresChart(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isDark
                  ? const Color(0xFF00E676).withOpacity(0.5)
                  : const Color(0xFF4CAF50).withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Overview',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            'ATS',
                            'Gram',
                            'Read',
                            'Verb',
                            'Form',
                            'Job',
                            'Coh',
                            'Key',
                          ];
                          return Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.atsScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.grammarScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.readabilityScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.verbQualityScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.formatScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.jobMatchScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.coherenceScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 7,
                      barRods: [
                        BarChartRodData(
                          toY: analysis.keywordDensityScore.toDouble(),
                          color: const Color(0xFF00C853),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresSection(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;

    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isDark
                  ? const Color(0xFF00E676).withOpacity(0.5)
                  : const Color(0xFF4CAF50).withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
          children: [
            ZoomIn(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.atsScore,
                label: 'ATS',
                description: 'Compatibility with tracking systems',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.grammarScore,
                label: 'Grammar',
                description: 'Spelling and grammar quality',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.readabilityScore,
                label: 'Readability',
                description: 'Ease of understanding',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 250),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.verbQualityScore,
                label: 'Action Verbs',
                description: 'Strength of action verbs',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.formatScore,
                label: 'Formatting',
                description: 'Visual structure quality',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 350),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.jobMatchScore,
                label: 'Job Match',
                description: 'Relevance to position',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.coherenceScore,
                label: 'Coherence',
                description: 'Logical flow and consistency',
              ),
            ),
            ZoomIn(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 500),
              child: ScoreCard(
                score: analysis.keywordDensityScore,
                label: 'Keyword Density',
                description: 'Keyword usage effectiveness',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTab(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    final hasFeedback =
        analysis.generalSuggestions.isNotEmpty ||
        analysis.atsOptimizationTips.isNotEmpty ||
        analysis.actionVerbSuggestions.isNotEmpty ||
        analysis.chronologyWarnings.isNotEmpty ||
        analysis.missingKeywords.isNotEmpty ||
        analysis.matchedKeywords.isNotEmpty ||
        analysis.grammarIssues.isNotEmpty ||
        analysis.atsOptimizationExamples.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInUp(
              child:
                  hasFeedback
                      ? _buildFeedbackSection(analysis, theme)
                      : Card(
                        elevation: 2,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isDark
                                    ? const Color(0xFF00E676).withOpacity(0.5)
                                    : const Color(0xFF4CAF50).withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No feedback available. Try re-analyzing or uploading a different resume.',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildFeedbackSection(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Feedback',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        if (analysis.generalSuggestions.isNotEmpty)
          FeedbackCard(
            title: 'General Suggestions',
            collapsible: true,
            child: FeedbackList(
              items: analysis.generalSuggestions,
              icon: Icons.lightbulb_outline,
              color: const Color(0xFF00C853),
            ),
          ),
        if (analysis.atsOptimizationTips.isNotEmpty)
          FeedbackCard(
            title: 'ATS Optimization Tips',
            collapsible: true,
            child: FeedbackList(
              items: analysis.atsOptimizationTips,
              icon: Icons.lightbulb_outline,
              color: const Color(0xFF00C853),
            ),
          ),
        if (analysis.actionVerbSuggestions.isNotEmpty)
          FeedbackCard(
            title: 'Action Verb Suggestions',
            collapsible: true,
            child: FeedbackList(
              items: analysis.actionVerbSuggestions,
              icon: Icons.arrow_forward,
              color: const Color(0xFF00C853),
            ),
          ),
        if (analysis.chronologyWarnings.isNotEmpty)
          FeedbackCard(
            title: 'Timeline Warnings',
            collapsible: true,
            child: FeedbackList(
              items: analysis.chronologyWarnings,
              icon: Icons.warning_amber,
              color: Colors.orange,
            ),
          ),
        if (analysis.matchedKeywords.isNotEmpty ||
            analysis.missingKeywords.isNotEmpty)
          FeedbackCard(
            title: 'Keyword Analysis',
            collapsible: true,
            child: KeywordFeedback(
              matchedKeywords: analysis.matchedKeywords,
              missingKeywords: analysis.missingKeywords,
            ),
          ),
        if (analysis.grammarIssues.isNotEmpty)
          FeedbackCard(
            title: 'Grammar Issues',
            collapsible: true,
            child: FeedbackList(
              items: analysis.grammarIssues,
              icon: Icons.error_outline,
              color: Colors.red,
            ),
          ),
        if (analysis.atsOptimizationExamples.isNotEmpty)
          FeedbackCard(
            title: 'ATS Optimization Examples',
            collapsible: true,
            child: FeedbackList(
              items: analysis.atsOptimizationExamples,
              icon: Icons.lightbulb,
              color: const Color(0xFF00C853),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionsTab(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInUp(
              child:
                  analysis.sections.isNotEmpty
                      ? FeedbackCard(
                        title: 'Section Analysis',
                        collapsible: false,
                        child: Column(
                          children:
                              analysis.sections.asMap().entries.map((entry) {
                                final section = entry.value;
                                return FadeInUp(
                                  delay: Duration(
                                    milliseconds: 100 * entry.key,
                                  ),
                                  child: SectionFeedbackCard(
                                    section: section,
                                    onImprovePressed:
                                        () => _showImprovementDialog(
                                          context,
                                          section,
                                        ),
                                  ),
                                );
                              }).toList(),
                        ),
                      )
                      : Card(
                        elevation: 2,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isDark
                                    ? const Color(0xFF00E676).withOpacity(0.5)
                                    : const Color(0xFF4CAF50).withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No section analysis available. Try re-analyzing or uploading a different resume.',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildConfidenceTab(AnalysisModel analysis, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInUp(
              child: FeedbackCard(
                title: 'Analysis Confidence',
                collapsible: false,
                child: Column(
                  children: [
                    ScoreCard(
                      score: analysis.confidenceScore,
                      label: 'Confidence',
                      description: 'Accuracy of the analysis',
                      compact: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This analysis has a confidence score of ${analysis.confidenceScore}%, indicating the reliability of the results.',
                      style: TextStyle(color: textColor, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  void _showImprovementDialog(BuildContext context, ResumeSection section) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Improve ${section.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Content:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(0xFF1B5E20).withOpacity(0.3)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            section.content
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: accentColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (section.improvementExamples.isNotEmpty) ...[
                      Text(
                        'Improvement Examples:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...section.improvementExamples.map(
                        (example) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle, size: 8, color: accentColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  example,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Suggestions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...section.suggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 8, color: accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                          backgroundColor:
                              isDark
                                  ? const Color(0xFF1B5E20).withOpacity(0.3)
                                  : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(color: accentColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
