import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/micro_interactions.dart';
import '../../core/constants/route_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/message_model.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/triage_provider.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const List<String> _quickReplies = [
    'Eviction / Housing Issue',
    'Family or Custody Dispute',
    'Workplace Discrimination',
    'Immigration Matter',
    'Debt or Financial Issue',
    'Criminal Record Query',
    'Other',
  ];

  bool _showQuickReplies = false;
  int _selectedBottomTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).currentLanguageCode;
      Provider.of<ConversationProvider>(
        context,
        listen: false,
      ).startConversation(langCode);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _showQuickReplies = true);
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _focusNode.unfocus();
    setState(() => _showQuickReplies = false);

    final langCode = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).currentLanguageCode;
    final convProvider = Provider.of<ConversationProvider>(
      context,
      listen: false,
    );
    final triageProvider = Provider.of<TriageProvider>(context, listen: false);

    await convProvider.sendUserMessage(text, langCode);
    _scrollToBottom();
    await triageProvider.evaluateTriage(
      convProvider.answers,
      convProvider.category ?? 'GENERAL',
      text,
      languageCode: langCode,
    );

    // Update conversation provider category from backend triage result
    if (triageProvider.backendCategory != null) {
      convProvider.setCategory(triageProvider.backendCategory);
    }

    if (convProvider.messages.length < 4 && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showQuickReplies = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final convProvider = Provider.of<ConversationProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final langCode = languageProvider.currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (convProvider.messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(convProvider, languageProvider, langCode, isDark),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 20,
                ),
                itemCount:
                    convProvider.messages.length +
                    (convProvider.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == convProvider.messages.length &&
                      convProvider.isTyping) {
                    return _buildTypingIndicator(isDark);
                  }
                  return _buildMessageItem(
                    convProvider.messages[index],
                    langCode,
                    isDark,
                  );
                },
              ),
            ),
            if (_showQuickReplies && convProvider.messages.length <= 2)
              _buildQuickReplies(isDark, langCode),
            // Triage screen bypassed - navigating directly to Document Upload
            // _buildTriageShortcutTile(isDark, langCode),
            const SizedBox(height: 8),
            _buildDocumentShortcutTile(isDark, langCode),
            const SizedBox(height: 10),
            _buildInputArea(convProvider, langCode, isDark),
            const SizedBox(height: 10),
            _buildDisclaimerText(isDark, langCode),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark, langCode),
    );
  }

  Widget _buildHeader(
    ConversationProvider convProvider,
    LanguageProvider langProvider,
    String langCode,
    bool isDark,
  ) {
    final stepText =
        'Question ${convProvider.currentQuestionStep} of about ${convProvider.totalQuestions}';
    final progress =
        convProvider.currentQuestionStep / convProvider.totalQuestions;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                stepText,
                style: AppTextStyles.caption(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.getText(langCode, 'yourSituationTitle'),
                style: AppTextStyles.titleLarge(
                  isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                ).copyWith(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              PopupMenuButton<String>(
                onSelected: (code) {
                  langProvider.setLanguage(code);
                  convProvider.setLanguage(code);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  PopupMenuItem(value: 'es', child: Text('🇪🇸 Español')),
                  PopupMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
                  PopupMenuItem(value: 'hi', child: Text('🇮🇳 Hindi')),
                  PopupMenuItem(value: 'mr', child: Text('🇮🇳 Marathi')),
                  PopupMenuItem(value: 'mix', child: Text('🌐 Easy Mix')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        langProvider.currentLanguageName,
                        style: AppTextStyles.label(
                          const Color(0xFF2563EB),
                        ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageModel msg, String langCode, bool isDark) {
    final isUser = msg.sender == MessageSender.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8, top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF2563EB)
                        : (isDark
                              ? AppColors.surfaceDark
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodyMedium(
                      isUser
                          ? Colors.white
                          : (isDark
                                ? AppColors.textPrimaryDark
                                : const Color(0xFF0F172A)),
                    ).copyWith(fontSize: 14, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
          if (!isUser && msg.options != null && msg.options!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.options!.map((opt) {
                  return InkWell(
                    onTap: () => _sendMessage(opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        opt,
                        style: AppTextStyles.label(
                          const Color(0xFF2563EB),
                        ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF2563EB),
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2563EB),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'AidRoute is writing...',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(bool isDark, String langCode) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final localizedReply = LocalizationService.getText(
            langCode,
            _quickReplies[index],
          );
          return InkWell(
            onTap: () => _sendMessage(localizedReply),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                localizedReply,
                style: AppTextStyles.label(
                  const Color(0xFF2563EB),
                ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(
    ConversationProvider convProvider,
    String langCode,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: 3,
            minLines: 1,
            style: AppTextStyles.bodyMedium(
              isDark ? AppColors.textPrimaryDark : const Color(0xFF1E293B),
            ).copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: LocalizationService.getText(
                langCode,
                'writeYourAnswerHere',
              ),
              hintStyle: AppTextStyles.bodyMedium(
                isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
              ).copyWith(fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            ),
            onSubmitted: _sendMessage,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.attach_file_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                tooltip: 'Attach document or notice',
                onPressed: () =>
                    Navigator.pushNamed(context, RouteConstants.documents),
              ),
              AnimatedPressScale(
                onTap: convProvider.isTyping
                    ? null
                    : () async {
                        if (_textController.text.trim().isNotEmpty) {
                          await _sendMessage(_textController.text);
                        } else {
                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              RouteConstants.caseSummary,
                            );
                          }
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    LocalizationService.getText(langCode, 'continueText'),
                    style: AppTextStyles.label(
                      Colors.white,
                    ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildTriageShortcutTile(bool isDark, String langCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryLight.withValues(alpha: 0.15)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.primaryLight : const Color(0xFFBFDBFE),
        ),
      ),
      child: ListTile(
        onTap: () async {
          final triageProvider = Provider.of<TriageProvider>(context, listen: false);
          final convProvider = Provider.of<ConversationProvider>(context, listen: false);
          await triageProvider.evaluateTriage(convProvider.answers);
          if (mounted) {
            Navigator.pushNamed(context, RouteConstants.triage);
          }
        },
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.assessment_outlined, color: Colors.white, size: 20),
        ),
        title: Text(
          LocalizationService.getText(langCode, 'proceedToTriage'),
          style: AppTextStyles.label(
            isDark ? AppColors.textPrimaryDark : const Color(0xFF1E40AF),
          ).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'View AI case classification & urgency rating',
          style: AppTextStyles.caption(
            isDark ? AppColors.textSecondaryDark : const Color(0xFF3B82F6),
          ).copyWith(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2563EB)),
      ),
    );
  }
  */

  Widget _buildDocumentShortcutTile(bool isDark, String langCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, RouteConstants.documents),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.article_outlined,
            color: Color(0xFF2563EB),
            size: 20,
          ),
        ),
        title: Text(
          LocalizationService.getText(langCode, 'addNoticeOrAgreement'),
          style: AppTextStyles.label(
            isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
          ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          LocalizationService.getText(langCode, 'datesAndDocumentDetails'),
          style: AppTextStyles.caption(
            isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ).copyWith(fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildDisclaimerText(bool isDark, String langCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF94A3B8),
          size: 14,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            LocalizationService.getText(langCode, 'intakeDisclaimer'),
            style: AppTextStyles.caption(
              isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ).copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(bool isDark, String langCode) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomTab,
        onTap: (index) {
          setState(() => _selectedBottomTab = index);
          if (index == 1)
            Navigator.pushNamed(context, RouteConstants.caseSummary);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_rounded),
            label: LocalizationService.getText(langCode, 'start'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline_rounded),
            label: LocalizationService.getText(langCode, 'myCase'),
          ),
        ],
      ),
    );
  }
}
