import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, dynamic>> _faqCategories = [
    {
      'title': 'General',
      'icon': Icons.info_outline,
      'color': Colors.blue,
      'faqs': [
        {
          'question': 'What is CIC Hub?',
          'answer':
              'CIC Hub is the official mobile application for Canadian International College students. It provides access to various university services, course information, and academic resources.',
        },
        {
          'question': 'How do I update my personal information?',
          'answer':
              'You can update your personal information by going to your Profile page and selecting the Edit Profile option. Some information may require approval from the administration.',
        },
        {
          'question': 'How do I contact the university?',
          'answer':
              'You can contact the university through the Support & Help Desk feature in the app, or by using the contact information provided in the About section.',
        },
      ],
    },
    {
      'title': 'Courses & Registration',
      'icon': Icons.school_outlined,
      'color': Colors.green,
      'faqs': [
        {
          'question': 'How do I register for courses?',
          'answer':
              'You can register for courses by going to the Registration page from the home screen. Select the courses you want to register for, choose your preferred time slots, and submit your registration.',
        },
        {
          'question': 'What is the course registration deadline?',
          'answer':
              'Course registration deadlines vary by semester. Please check the announcements section or contact the registrar\'s office for specific dates.',
        },
        {
          'question': 'How do I drop a course?',
          'answer':
              'To drop a course, go to the Registration page, find the course in your registered courses list, and select the drop option. Note that dropping courses after certain deadlines may result in financial penalties.',
        },
      ],
    },
    {
      'title': 'Payments & Fees',
      'icon': Icons.payment_outlined,
      'color': Colors.orange,
      'faqs': [
        {
          'question': 'How do I pay my tuition fees?',
          'answer':
              'You can pay your tuition fees through the Payment section in the app. We accept credit/debit cards and bank transfers. You can also pay in person at the finance office.',
        },
        {
          'question': 'What is the payment deadline?',
          'answer':
              'Payment deadlines are typically at the beginning of each semester. Late payments may incur additional fees. Check the announcements section for specific dates.',
        },
        {
          'question': 'Are there any scholarships available?',
          'answer':
              'Yes, the university offers various scholarships based on academic merit, financial need, and other criteria. Visit the financial aid office or check the university website for more information.',
        },
      ],
    },
    {
      'title': 'Technical Issues',
      'icon': Icons.computer_outlined,
      'color': Colors.purple,
      'faqs': [
        {
          'question': 'I forgot my password. How do I reset it?',
          'answer':
              'You can reset your password by clicking on the "Forgot Password" link on the login page. Follow the instructions sent to your registered email address.',
        },
        {
          'question': 'The app is not working properly. What should I do?',
          'answer':
              'Try closing and reopening the app. If the issue persists, try clearing the app cache or reinstalling the app. If you still experience problems, contact technical support through the Support & Help Desk.',
        },
        {
          'question': 'How do I update the app?',
          'answer':
              'The app should update automatically through your device\'s app store. If not, you can manually check for updates in the Google Play Store or Apple App Store.',
        },
      ],
    },
  ];

  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Answers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Browse through our frequently asked questions',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Category tabs
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _faqCategories.length,
              itemBuilder: (context, index) {
                final category = _faqCategories[index];
                final isSelected = _selectedCategoryIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category['color'].withOpacity(0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? category['color']
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: category['color'],
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['title'],
                          style: TextStyle(
                            color: isSelected
                                ? category['color']
                                : Colors.grey[800],
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // FAQ list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _faqCategories[_selectedCategoryIndex]['faqs'].length,
              itemBuilder: (context, index) {
                final faq = _faqCategories[_selectedCategoryIndex]['faqs'][index];
                return _buildFaqItem(
                  faq['question'],
                  faq['answer'],
                  _faqCategories[_selectedCategoryIndex]['color'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        childrenPadding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.question_mark, color: color, size: 20),
        ),
        iconColor: color,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
