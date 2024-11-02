import 'package:flutter/material.dart';

class TermsOfServiceWidget extends StatelessWidget {
  const TermsOfServiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service', style: TextStyle(fontFamily: 'Poppins', fontSize: 16),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Introduction'),
            _buildNormalText(
              'These Terms of Service ("Terms") govern your use of our mobile application "Maarifa." By accessing or using the Maarifa App, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use the Maarifa App.',
            ),
            _buildSectionTitle('2. Channel Creation'),
            _buildBoldText('• Eligibility:'),
            _buildNormalText(
              'To create a channel on the Maarifa App, you must agree to these Terms.',
            ),
            _buildBoldText('• Channel Purpose:'),
            _buildNormalText(
              'When creating a channel, you must specify its purpose and provide a relevant description.',
            ),
            _buildBoldText('• Content Guidelines:'),
            _buildNormalText(
              'You are responsible for ensuring that all content created or shared on your channel adheres to these Terms and applicable laws.',
            ),
            _buildBoldText('• Adherence to Aqeedah Ahl al-Sunnah wa’l-Jamaa’ah:'),
            _buildNormalText(
              'All content you create or share through the Maarifa App must adhere to the Aqeedah Ahla Sunnah wal Jamaah. Any content that deviates from this principle will be considered a violation of these Terms.',
            ),
            _buildBoldText('• Relevant Content:'),
            _buildNormalText(
              'Your content must be relevant to the purpose and description of the channel you create. Any content that is unrelated or off-topic will be considered a violation of these Terms.',
            ),
            _buildBoldText('• Admin Oversight:'),
            _buildNormalText(
              'The Maarifa App\'s administrator reserves the right to review and monitor your content for compliance with these Terms.',
            ),
            _buildBoldText('• Channel Deletion:'),
            _buildNormalText(
              'If the administrator determines that your content violates these Terms, your channel may be deleted without notice. You will be notified of the reason for deletion via email.',
            ),
            _buildSectionTitle('3. User Activity Monitoring'),
            _buildBoldText('• Data Collection:'),
            _buildNormalText(
              'The Maarifa App may collect data about your activities within the app, including your use of features like quizzes, Quran, and Hadith knowledge. This data is used to provide you with personalized statistics and insights.',
            ),
            _buildBoldText('• Data Usage:'),
            _buildNormalText(
              'Your data may be used to analyze your progress, identify areas for improvement, and offer tailored recommendations.',
            ),
            _buildSectionTitle('4. Data Collection and Usage'),
            _buildBoldText('• Consent:'),
            _buildNormalText(
              'By using the Maarifa App, you consent to the collection, storage, and processing of your personal data as described in our Privacy Policy.',
            ),
            _buildBoldText('• Firebase Storage:'),
            _buildNormalText(
              'Your data may be stored and processed on Firebase servers. Firebase is committed to protecting your data and complies with applicable data protection laws.',
            ),
            _buildSectionTitle('5. Intellectual Property'),
            _buildBoldText('• Ownership:'),
            _buildNormalText(
              'All intellectual property rights in the Maarifa App, including its content, features, and functionality, are owned by Maarifa or its licensors.',
            ),
            _buildBoldText('• User Content:'),
            _buildNormalText(
              'You retain ownership of the content you create and share through the Maarifa App. However, by sharing your content, you grant us a non-exclusive, worldwide, royalty-free license to use, reproduce, modify, adapt, publish, perform, display, and distribute your content.',
            ),
            _buildSectionTitle('6. Disclaimer of Warranties'),
            _buildNormalText(
              'THE MAARIFA APP IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. WE DISCLAIM ALL WARRANTIES, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.',
            ),
            _buildSectionTitle('7. Limitation of Liability'),
            _buildNormalText(
              'IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES, INCLUDING, BUT NOT LIMITED TO, DAMAGES FOR LOSS OF PROFITS, GOODWILL, USE, DATA, OR OTHER INTANGIBLE LOSSES (EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES), ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THE MAARIFA APP OR THESE TERMS.',
            ),
            _buildSectionTitle('8. Amendments'),
            _buildNormalText(
              'We may update these Terms from time to time. We will notify you of any significant changes by posting the revised Terms on the Maarifa App or by contacting you directly. Your continued use of the Maarifa App after the effective date of any such changes constitutes your acceptance of the revised Terms.',
            ),
            _buildSectionTitle('9. Governing Law'),
            _buildNormalText(
              'These Terms shall be governed by and construed in accordance with the laws of Pakistan. Any dispute arising out of or in connection with these Terms shall be submitted to the exclusive jurisdiction of the courts of Pakistan.',
            ),
            const SizedBox(height: 20),
            _buildNormalText(
              'By using the Maarifa App, you agree to these Terms of Service.',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
            fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // Helper method for normal text
  Widget _buildNormalText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.0,fontFamily: 'Poppins'),

      ),
    );
  }

  // Helper method for bolded sub-sections
  Widget _buildBoldText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
            fontFamily: 'Poppins'
        ),
      ),
    );
  }
}
