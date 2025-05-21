import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
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

  const ResumeAnalysisScreen({super.key, required this.args});

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen>
    with TickerProviderStateMixin {
  late Future<AnalysisModel> _analysisFuture;
  late final TabController _tabController;
  late final AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();
    _startAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _analysisFuture = apiService.analyzeResume(
        extractedText: widget.args['extractedText'] ?? '',
        jobDescription: widget.args['jobDescription'] ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = widget.args['fileName'] ?? 'Resume Analysis';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startAnalysis,
            tooltip: 'Re-analyze Resume',
            color: Colors.white,
            hoverColor: Colors.white24,
          ),
        ],
        elevation: 4,
        shadowColor: Colors.black45,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
          onPressed: _startAnalysis,
          backgroundColor: const Color(0xFF4CAF50),
          tooltip: 'Re-analyze',
          hoverColor: const Color(0xFF388E3C),
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
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const AnalysisLoading();
    }

    if (snapshot.hasError) {
      return AnalysisError(
        message: snapshot.error.toString(),
        onRetry: _startAnalysis,
      );
    }

    if (!snapshot.hasData) {
      return AnalysisError(
        message:
            'No analysis data available. Please re-analyze or upload a resume.',
        onRetry: _startAnalysis,
      );
    }

    final analysis = snapshot.data!;
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
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: FadeInUp(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
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
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No feedback available. Try re-analyzing or uploading a different resume.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Feedback',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
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
              color: theme.colorScheme.primary,
            ),
          ),
        if (analysis.atsOptimizationTips.isNotEmpty)
          FeedbackCard(
            title: 'ATS Optimization Tips',
            collapsible: true,
            child: FeedbackList(
              items: analysis.atsOptimizationTips,
              icon: Icons.lightbulb_outline,
              color: theme.colorScheme.primary,
            ),
          ),
        if (analysis.actionVerbSuggestions.isNotEmpty)
          FeedbackCard(
            title: 'Action Verb Suggestions',
            collapsible: true,
            child: FeedbackList(
              items: analysis.actionVerbSuggestions,
              icon: Icons.arrow_forward,
              color: theme.colorScheme.primary,
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
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionsTab(AnalysisModel analysis, ThemeData theme) {
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No section analysis available. Try re-analyzing or uploading a different resume.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground,
                      ),
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
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Content:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
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
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Color(0xFF388E3C),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...section.improvementExamples.map(
                        (example) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Color(0xFF388E3C),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  example,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...section.suggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF388E3C),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: Theme.of(context).textTheme.bodyMedium,
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
                          foregroundColor: const Color(0xFF4CAF50),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close'),
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
