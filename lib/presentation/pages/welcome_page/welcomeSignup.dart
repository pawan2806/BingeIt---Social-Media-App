import 'package:bingeit/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:bingeit/constants.dart';
import 'package:bingeit/models/info_model.dart';
import 'package:bingeit/presentation/pages/splash_page/splash_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/gestures.dart';
import 'package:bingeit/notifications/pushNotif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeSignup extends StatefulWidget {
  @override
  _WelcomeSignupState createState() => _WelcomeSignupState();
}

class _WelcomeSignupState extends State<WelcomeSignup> {
  bool isAgreed = false;
  bool _obscureText = true;
  final _debouncer = Debouncer(milliseconds: 500);

  Widget getUsernameStatusIcon(SignInFormState state) {
    if (state.isUserTypingUsername) {
      return Icon(null);
    } else {
      return state.isUsernameAvailable
          ? Icon(
        Icons.check,
        color: Colors.greenAccent,
      )
          : Icon(
        Icons.clear,
        color: Colors.red,
      );
    }
  }

  void _launchWebPage(BuildContext context) async {
    try {
      if (await canLaunch("https://www.bingeit.com/")) {
        await launch("https://www.bingeit.com/");
      } else {
        throw 'Could not launch web page';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: BlocConsumer<SignInFormBloc, SignInFormState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  duration: Duration(seconds: 1),
                ),
              );
            }
            if (state.isAuthStateChanged) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SplashPage(),
                ),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              children: [
                Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                            top: 10.0,
                          ),
                          height: MediaQuery.of(context).size.height * 0.4,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 30.0,
                                      color: dAccent,
                                    ),
                                  ),

                                  Text(
                                    'Register Now',
                                    style: GoogleFonts.lexendExa(
                                      color: dAccent,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                ],
                              ),

                              SizedBox(height: 20.0),
                              Center(
                                child: Hero(
                                  tag: infos[1].imageUrl,
                                  child: Image(
                                    height: 250.0,
                                    width: 250.0,
                                    image: AssetImage('assets/images/info1.jpg',),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),



                            ],
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
                state.isSubmitting ? LinearProgressIndicator(value: null) : Text(""),
                Container(
                  decoration: BoxDecoration(
                    color: darkBG,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, top :20),
                          child: Text(

                            'sign up',
                            style: GoogleFonts.lexendExa(

                              color: Colors.blueGrey,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, top: 8, ),
                          child: Text(

                            'Please enter the following details.',
                            style: GoogleFonts.lexendExa(

                              color: Colors.blueGrey,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_outline,

                              color: dAccent,
                            ),
                            labelText: 'Full Name',
                          ),
                          onChanged: (value) => context.read<SignInFormBloc>().add(
                            SignInFormEvent.fullNameChanged(value),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
                        child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                              LengthLimitingTextInputFormatter(30),
                            ],
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_rounded,
                                color: dAccent,
                              ),
                              labelText: 'Username',
                              suffixIcon: getUsernameStatusIcon(state),
                            ),
                            onChanged: (value) {
                              context.read<SignInFormBloc>().add(
                                SignInFormEvent.usernameChanged(),
                              );
                              _debouncer.run(() {
                                context.read<SignInFormBloc>().add(
                                  SignInFormEvent.usernameBeingChecked(value),
                                );
                              });
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
                        child: TextFormField(
                          autocorrect: false,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: dAccent,
                            ),
                            labelText: 'Email',
                          ),
                          onChanged: (value) => context.read<SignInFormBloc>().add(
                            SignInFormEvent.emailChanged(value),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 25),
                        child: TextFormField(
                          autocorrect: false,
                          obscureText:  _obscureText,
                          decoration:  InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: dAccent,
                            ),
                            labelText: 'Password (at least 6 characters)',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: dAccent,
                              ),
                              onPressed: () {
                                setState(() => _obscureText= !_obscureText);
                              },),
                          ),
                          onChanged: (value) => context.read<SignInFormBloc>().add(
                            SignInFormEvent.passwordChanged(value),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(

                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Terms of Service'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Text('Please read this Terms of Service agreement before using the services offered by Bingeit (also referred as "Company", "us" or “we”). These terms of service set forth the legally binding terms and conditions for your use of the application at Bingeit (the “App”) and the services, features, content, products and applications offered by it (collectively with the App, the “Service” or “Services”).'),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("ACCEPTANCE OF TERMS",

                                                style: st,),
                                            ),
                                            Text('By registering for and/or using the Service in any way, including without limitation merely visiting the App, you expressly acknowledge that you have read and agree to be bound by all of the terms and conditions herein (the Terms), the Privacy Policy, our Code of Conduct and other guidelines and policies we may publish on the App from time to time, each of which is incorporated herein by reference. This Service is intended for lawful use by persons over eighteen (18) years of age. Bingeit reserves the right to change these Terms, the Privacy Policy and other guidelines and policies posted on the App from time to time at its sole discretion, with or without notice.Your continued use of the Service constitutes your acceptance of the revised Terms, and your use of the Service will be subject to the most current version of these Terms, policies, and guidelines posted on the Site at the time of such use.  If you breach any part of these Terms, your authorization to use the Service will automatically terminate. ' ),

                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("ACCESS TO THE SERVICE", style: st,),
                                            ),
                                            Text("Subject to these Terms, Company may offer to provide certain Services, as described more fully on the App, which are solely for your own use, and not for the use or benefit of any third party. Services may include any information content provided for or distributed to you (over the Internet, in person during an event or otherwise), any services performed for you, and any applications or widgets offered to you, whether any such Services are provided by Company or, subject to the terms set out under the “Third Party Sites and Services” section below, by third party providers authorized by Company."
                                                ),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("PROFILE ACCOUNT", style: st,),
                                            ),
                                            Text("When you create an account, you guarantee that you are above the age of 12 and that the information you provide us is accurate, complete, and will remain current at all times. Inaccurate, incomplete, or obsolete information may result in the termination of your account. You are responsible for maintaining the confidentiality of your account and password, including but not limited to the restriction of access to your computer and account. You agree to accept responsibility for any and all activities or actions that occur under your account and password, whether your password is for our Service or a third-party service such as Google Sign In. If you choose to set up a profile account or membership account on the App, you will become a “User.”  During the profile registration process, you will be asked to choose a password. You agree to keep your password confidential.  Users are entirely responsible for any and all activities which occur under their account whether authorized or not authorized, unless access to a user’s user name and/or password was obtained by a third party through no fault or negligence of User’s own. User agrees to notify Company of any unauthorized use of User’s account or any other breach of account security as soon as it becomes known to User.  Any rights to use Services offered to a User are personal to that User and not for commercial use without the express written consent of Company. You are solely responsible for your interactions with other Users, third party developers or any other parties with whom you interact through the Service. Company reserves the right, but has no obligation, to become involved in any way with any disputes.We take no responsibility and assume no liability for Content you or any third-party posts. However, by posting Content you grant us the right and license to use, modify, publicly perform, publicly display, reproduce, and distribute such Content. You agree this license includes the right for us to make your Content available to other users of the Service, who may also use your Content subject to these Terms. We have the right but not the obligation to monitor and edit all Content posted by users. In addition, all Content we use in providing the Service is our intellectual property or used with permission. You may not distribute, modify, transmit, reuse, download, repost, copy, or use said Content, whether in whole or in part, for commercial purposes or for personal gain, without express advance written permission from us."
                                                ""),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("RULES AND CONDUCT", style: st,),
                                            ),
                                            Text("""The Service is provided for personal, non-commercial use only. You are solely responsible for all of your activity in connection with the Service. Bingeit may, in its sole discretion, delete irresponsible content or content that is otherwise inconsistent with the purpose of Bingeit social media. To the extent applicable, Bingeit reserves the right to block any user that fails to follow these Terms of Use. Examples of inappropriate or off-topic messages include, but are not limited to, the following:
~ Defamatory, malicious, obscene, intimidating, discriminatory, harassing or threatening comments or hate propaganda;
~ Calls to violence of any kind;
~ Activity that violates any law or regulation;
~ Attempts to target Bingeit or Bingeit Followers to offer goods or services, of either a commercial or private nature;
~ Spam directed at Bingeit or any Bingeit's Followers, including any form of automatically generated content or repeatedly posting the same content;
~ Content that includes medical advice that may be unsolicited and/or unverified;
~ Content deemed to constitute an unapproved use of any of our products or is otherwise false or misleading;
~ Any potential infringement upon any intellectual property rights, including but not limited to, brand names, trade names, logos, copyrights or trade secrets of any person, business or place;
~ Other content deemed to be off-topic or to disrupt the purposes of the channel, its Followers, and its sense of community and acceptance; and
~ Content posted by fake or anonymous users.
~ Posts that are knowingly inaccurate, deceptive, fraudulent, false, or untruthful.
~ Posts that are libelous, obscene, defamatory, offensive, profane, unlawful, promotional of any crime or invasive of another’s privacy.
~ Posts that are unsolicited advertising or use of junk, “spam”, or bulk transmission, or “phishing”.
~ Posts that are intended to result in the transmission and/or distribution of a computer or mobile device virus.
~ Posts that are meant to impersonate any person or entity.
~ Data that contains software viruses or any other computer code, files or programs designed to interrupt, destroy or limit the functionality of any computer software or hardware or telecommunications equipment.
~ Content which threatens the unity, integrity, defence, security or sovereignty of India, friendly relations with foreign states, or public order or causes incitement to the commission of any cognizable offence or prevents investigation of any offence or is insulting any other nation.
~ Sexually explicit, obscene content or content which violates privacy rights or hurts religious sentiments.
~ Sensitive Personal Information

Further, on Bingeit you shall not :
~ Impersonate any person or entity or falsely state or otherwise misrepresent your affiliation with a person or entity;
~ Forge headers or otherwise manipulate identifiers in order to disguise the origin of any data transmitted to other users;
~ Transmit, access or communicate any data that you do not have a right to transmit under any law or under contractual or fiduciary relationships (such as inside information, proprietary and confidential information learned or disclosed as part of employment relationships or under non-disclosure agreements);
~ Transmit, access, or communicate any data that infringes any patent, trademark, trade secret, copyright or other proprietary rights of any party;
~ Intentionally or unintentionally violate any applicable local, state, national or international law, including securities exchange and any regulations requirements, procedures or policies in force from time to time relating to the social media;
~ Modify, delete or damage any information contained on the personal computer of any other user;
~ Use the social media in any way related to gambling or illegal lotteries or illegal sweepstakes;
~ Harm the social media including using any program or other mechanism to slow or “crash” the network;
~ Allow usage by others in such a way as to violate these Terms of Use;
                                          """,
                                              textAlign: TextAlign.start,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("THIRD-PARTY SITES AND SERVICES", style: st,),
                                            ),
                                            Text("""The Service may include links to other websites, services or resources on the Internet that are owned and operated by online merchants and other third parties. You acknowledge that we are not responsible for the availability, content, legality, appropriateness or any other aspect of any third-party site. Your use of third-party sites is at your own risk and subject to the terms of use and privacy policies of each site, for which we are not responsible and which we encourage you to review.
Certain Services, including many of our events, are organized by third parties.  Additionally, certain other Services, including registration, scheduling and mobile applications, are provided by third parties.  Company offers no guarantees and assumes no responsibility or liability of any type with respect to content, products and services provided by any third party.
"""),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("INDEMNIFICATION", style: st,),
                                            ),
                                            Text("""You agree to defend, indemnify and hold harmless Bingeit and its licensee and licensors, and their employees, contractors, agents, officers and directors against any and all claims, damages, obligations, losses, liabilities, costs or debt, and expenses (including but not limited to attorney's fees), resulting from or arising out of (a) use of the Service by you or any person using your account and password; (b) a breach of these Terms; or (c) Content posted through our Service.
"""),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("NO WAIVER", style: st,),
                                            ),
                                            Text("""Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have had between us regarding the Service.
"""),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("LIMITATION OF LIABILITY", style: st,),
                                            ),
                                            Text("In no event shall we nor our directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses resulting from (i) your use of or inability to use the Service; (ii) any conduct or content of any third-party on the Service; (iii) any content obtained from the Service; and (iv) unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage, and even if a remedy set forth herein is found to have failed of its essential purpose."),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("MODIFICATIONS AND INTERRUPTION TO SERVICE", style: st,),
                                            ),
                                            Text("Bingeit reserves the right to modify or discontinue any element of the Service with or without notice to you, and Company will not be liable to you or any third party should Company exercise this right. You acknowledge and accept that Company does not guarantee continuous, uninterrupted or secure access to the Service and operation of the Service may be interfered with or adversely affected by numerous factors or circumstances outside of our control."),
                                            Padding(
                                              padding: const EdgeInsets.only(top : 15.0),
                                              child: Text("MISCELANEOUS", style: st,),
                                            ),
                                            Text("If any provision of these Terms of Use shall be unlawful, void, or for any reason unenforceable, then that provision shall be deemed severable from this agreement and shall not affect the validity and enforceability of any remaining provisions. This is the entire agreement between the parties relating to the matters contained herein.")


                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context, rootNavigator: true).pop();
                                          },
                                          style: TextButton.styleFrom(
                                            primary: Color(0xFF96baff),
                                          ),
                                          child: Text("Back"),
                                        ),
                                      ],
                                    )
                                );


                          },
                              style: kWatchedButton,
                              child: Text("Terms of Service")),
                          ElevatedButton(

                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Privacy Policy'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Text("""
Last updated: January 19, 2022

This Privacy Policy describes Our policies and procedures on the collection,
use and disclosure of Your information when You use the Service and tells You
about Your privacy rights and how the law protects You.

We use Your Personal data to provide and improve the Service. By using the
Service, You agree to the collection and use of information in accordance with
this Privacy Policy. This Privacy Policy has been created with the help of the


Interpretation and Definitions  
==============================

Interpretation  
--------------

The words of which the initial letter is capitalized have meanings defined
under the following conditions. The following definitions shall have the same
meaning regardless of whether they appear in singular or in plural.

Definitions  
-----------

For the purposes of this Privacy Policy:

  * Account means a unique account created for You to access our Service or
    parts of our Service.

  * Affiliate means an entity that controls, is controlled by or is under
    common control with a party, where "control" means ownership of 50% or
    more of the shares, equity interest or other securities entitled to vote
    for election of directors or other managing authority.

  * Application means the software program provided by the Company downloaded
    by You on any electronic device, named Bingeit

  * Company (referred to as either "the Company", "We", "Us" or "Our" in this
    Agreement) refers to Bingeit.

  * Country refers to: Delhi, India

  * Device means any device that can access the Service such as a computer, a
    cellphone or a digital tablet.

  * Personal Data is any information that relates to an identified or
    identifiable individual.

  * Service refers to the Application.

  * Service Provider means any natural or legal person who processes the data
    on behalf of the Company. It refers to third-party companies or
    individuals employed by the Company to facilitate the Service, to provide
    the Service on behalf of the Company, to perform services related to the
    Service or to assist the Company in analyzing how the Service is used.

  * Third-party Social Media Service refers to any website or any social
    network website through which a User can log in or create an account to
    use the Service.

  * Usage Data refers to data collected automatically, either generated by the
    use of the Service or from the Service infrastructure itself (for example,
    the duration of a page visit).

  * You means the individual accessing or using the Service, or the company,
    or other legal entity on behalf of which such individual is accessing or
    using the Service, as applicable.


Collecting and Using Your Personal Data  
=======================================

Types of Data Collected  
-----------------------

Personal Data  
~~~~~~~~~~~~~

While using Our Service, We may ask You to provide Us with certain personally
identifiable information that can be used to contact or identify You.
Personally identifiable information may include, but is not limited to:

  * Email address

  * First name and last name

  * Usage Data


Usage Data  
~~~~~~~~~~

Usage Data is collected automatically when using the Service.

Usage Data may include information such as Your Device's Internet Protocol
address (e.g. IP address), browser type, browser version, the pages of our
Service that You visit, the time and date of Your visit, the time spent on
those pages, unique device identifiers and other diagnostic data.

When You access the Service by or through a mobile device, We may collect
certain information automatically, including, but not limited to, the type of
mobile device You use, Your mobile device unique ID, the IP address of Your
mobile device, Your mobile operating system, the type of mobile Internet
browser You use, unique device identifiers and other diagnostic data.

We may also collect information that Your browser sends whenever You visit our
Service or when You access the Service by or through a mobile device.

Information from Third-Party Social Media Services  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Company allows You to create an account and log in to use the Service
through the following Third-party Social Media Services:

  * Google
  * Facebook
  * Twitter

If You decide to register through or otherwise grant us access to a Third-
Party Social Media Service, We may collect Personal data that is already
associated with Your Third-Party Social Media Service's account, such as Your
name, Your email address, Your activities or Your contact list associated with
that account.

You may also have the option of sharing additional information with the
Company through Your Third-Party Social Media Service's account. If You choose
to provide such information and Personal Data, during registration or
otherwise, You are giving the Company permission to use, share, and store it
in a manner consistent with this Privacy Policy.

Use of Your Personal Data  
-------------------------

The Company may use Personal Data for the following purposes:

  * To provide and maintain our Service , including to monitor the usage of
    our Service.

  * To manage Your Account: to manage Your registration as a user of the
    Service. The Personal Data You provide can give You access to different
    functionalities of the Service that are available to You as a registered
    user.

  * For the performance of a contract: the development, compliance and
    undertaking of the purchase contract for the products, items or services
    You have purchased or of any other contract with Us through the Service.

  * To contact You: To contact You by email, telephone calls, SMS, or other
    equivalent forms of electronic communication, such as a mobile
    application's push notifications regarding updates or informative
    communications related to the functionalities, products or contracted
    services, including the security updates, when necessary or reasonable for
    their implementation.

  * To provide You with news, special offers and general information about
    other goods, services and events which we offer that are similar to those
    that you have already purchased or enquired about unless You have opted
    not to receive such information.

  * To manage Your requests: To attend and manage Your requests to Us.

  * For business transfers: We may use Your information to evaluate or conduct
    a merger, divestiture, restructuring, reorganization, dissolution, or
    other sale or transfer of some or all of Our assets, whether as a going
    concern or as part of bankruptcy, liquidation, or similar proceeding, in
    which Personal Data held by Us about our Service users is among the assets
    transferred.

  * For other purposes : We may use Your information for other purposes, such
    as data analysis, identifying usage trends, determining the effectiveness
    of our promotional campaigns and to evaluate and improve our Service,
    products, services, marketing and your experience.


We may share Your personal information in the following situations:

  * With Service Providers: We may share Your personal information with
    Service Providers to monitor and analyze the use of our Service, to
    contact You.
  * For business transfers: We may share or transfer Your personal information
    in connection with, or during negotiations of, any merger, sale of Company
    assets, financing, or acquisition of all or a portion of Our business to
    another company.
  * With Affiliates: We may share Your information with Our affiliates, in
    which case we will require those affiliates to honor this Privacy Policy.
    Affiliates include Our parent company and any other subsidiaries, joint
    venture partners or other companies that We control or that are under
    common control with Us.
  * With business partners: We may share Your information with Our business
    partners to offer You certain products, services or promotions.
  * With other users: when You share personal information or otherwise
    interact in the public areas with other users, such information may be
    viewed by all users and may be publicly distributed outside. If You
    interact with other users or register through a Third-Party Social Media
    Service, Your contacts on the Third-Party Social Media Service may see
    Your name, profile, pictures and description of Your activity. Similarly,
    other users will be able to view descriptions of Your activity,
    communicate with You and view Your profile.
  * With Your consent : We may disclose Your personal information for any
    other purpose with Your consent.

Retention of Your Personal Data  
-------------------------------

The Company will retain Your Personal Data only for as long as is necessary
for the purposes set out in this Privacy Policy. We will retain and use Your
Personal Data to the extent necessary to comply with our legal obligations
(for example, if we are required to retain your data to comply with applicable
laws), resolve disputes, and enforce our legal agreements and policies.

The Company will also retain Usage Data for internal analysis purposes. Usage
Data is generally retained for a shorter period of time, except when this data
is used to strengthen the security or to improve the functionality of Our
Service, or We are legally obligated to retain this data for longer time
periods.

Transfer of Your Personal Data  
------------------------------

Your information, including Personal Data, is processed at the Company's
operating offices and in any other places where the parties involved in the
processing are located. It means that this information may be transferred to —
and maintained on — computers located outside of Your state, province, country
or other governmental jurisdiction where the data protection laws may differ
than those from Your jurisdiction.

Your consent to this Privacy Policy followed by Your submission of such
information represents Your agreement to that transfer.

The Company will take all steps reasonably necessary to ensure that Your data
is treated securely and in accordance with this Privacy Policy and no transfer
of Your Personal Data will take place to an organization or a country unless
there are adequate controls in place including the security of Your data and
other personal information.

Disclosure of Your Personal Data  
--------------------------------

Business Transactions  
~~~~~~~~~~~~~~~~~~~~~

If the Company is involved in a merger, acquisition or asset sale, Your
Personal Data may be transferred. We will provide notice before Your Personal
Data is transferred and becomes subject to a different Privacy Policy.

Law enforcement  
~~~~~~~~~~~~~~~

Under certain circumstances, the Company may be required to disclose Your
Personal Data if required to do so by law or in response to valid requests by
public authorities (e.g. a court or a government agency).

Other legal requirements  
~~~~~~~~~~~~~~~~~~~~~~~~

The Company may disclose Your Personal Data in the good faith belief that such
action is necessary to:

  * Comply with a legal obligation
  * Protect and defend the rights or property of the Company
  * Prevent or investigate possible wrongdoing in connection with the Service
  * Protect the personal safety of Users of the Service or the public
  * Protect against legal liability

Security of Your Personal Data  
------------------------------

The security of Your Personal Data is important to Us, but remember that no
method of transmission over the Internet, or method of electronic storage is
100% secure. While We strive to use commercially acceptable means to protect
Your Personal Data, We cannot guarantee its absolute security.

Children's Privacy  
==================

Our Service does not address anyone under the age of 13. We do not knowingly
collect personally identifiable information from anyone under the age of 13.
If You are a parent or guardian and You are aware that Your child has provided
Us with Personal Data, please contact Us. If We become aware that We have
collected Personal Data from anyone under the age of 13 without verification
of parental consent, We take steps to remove that information from Our
servers.

If We need to rely on consent as a legal basis for processing Your information
and Your country requires consent from a parent, We may require Your parent's
consent before We collect and use that information.

Links to Other Websites  
=======================

Our Service may contain links to other websites that are not operated by Us.
If You click on a third party link, You will be directed to that third party's
site. We strongly advise You to review the Privacy Policy of every site You
visit.

We have no control over and assume no responsibility for the content, privacy
policies or practices of any third party sites or services.

Changes to this Privacy Policy  
==============================

We may update Our Privacy Policy from time to time. We will notify You of any
changes by posting the new Privacy Policy on this page.

We will let You know via email and/or a prominent notice on Our Service, prior
to the change becoming effective and update the "Last updated" date at the top
of this Privacy Policy.

You are advised to review this Privacy Policy periodically for any changes.
Changes to this Privacy Policy are effective when they are posted on this
page.

Contact Us  
==========

If you have any questions about this Privacy Policy, You can contact us:

  * By email: bingeit28@gmail.com

                                            """),

                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context, rootNavigator: true).pop();
                                          },
                                          style: TextButton.styleFrom(
                                            primary: Color(0xFF96baff),
                                          ),
                                          child: Text("Back"),
                                        ),
                                      ],
                                    )
                                );


                              },
                              style: kWatchedButton,
                              child: Text('Privacy Policy')),

                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ListTile(
                          leading: Checkbox(
                            activeColor: Color(0xFF6398ff),
                            value: isAgreed,
                            onChanged: (bool value) {
                              setState(() {
                                isAgreed = value;
                              });
                            },
                          ),

                          title: RichText(
                            text: TextSpan(
                              text: "I confirm that I am over 18 and I agree to the Terms of Serice and Privacy Policy.",
                              style: TextStyle(color: Colors.grey[300]),
                              children: [
                                // TextSpan(
                                //   text: "Terms of Service",
                                //   style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[50]),
                                //   recognizer: TapGestureRecognizer()
                                //     ..onTap = () {
                                //        //termsOfUse();
                                //     },
                                // ),
                                // TextSpan(text: " and ", style: TextStyle()),
                                // TextSpan(
                                //   text: "Privacy Policy",
                                //   style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[50]),
                                //   recognizer: TapGestureRecognizer()
                                //     ..onTap = () {
                                //       _launchWebPage(context);
                                //     },
                                // ),
                              ],
                            ),
                          ),

                        ),

                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                        child: ElevatedButton(
                          style: kNotWatchedButton,
                          onPressed: () {
                            !isAgreed
                                ? ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("You need to check the checkbox before continuing"),
                                duration: Duration(seconds: 1),
                              ),
                            )
                                : context.read<SignInFormBloc>().add(
                              SignInFormEvent.registerPressed(),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text("Register"),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class dialog extends StatelessWidget {
  const dialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Confirm if you want to remove from Watched"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Note: this action cannot be undone."),
        ],
      ),
      actions: [

        TextButton(
          onPressed: () {

            Navigator.of(context, rootNavigator: true).pop();
          },
          style: TextButton.styleFrom(
            primary: Color(0xFF96baff),
          ),
          child: Text("Back"),
        ),
      ],
    );
  }
}
