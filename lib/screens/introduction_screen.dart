import 'package:donateer/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class IntroductionScreen extends StatefulWidget {

  const IntroductionScreen ({ Key? key }): super(key: key);

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState
    extends State<IntroductionScreen> {

  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        body: SafeArea(
          minimum: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 50,
                child: Column(
                  children: <Widget>[
                    Text('Introduction',
                        style: Theme.of(context).textTheme.headline1),
                    const SizedBox(height: 15),
                    const Text(
                        'This App helps you do good in a newer and more effective form: "Donateer" your work, make an impact, and track it!\n\n' 'On this App, you can choose your favorite charities and pledge your time at work toward helping your favorite charities. By signing up as a "donateer", your contributions to important charities is no longer constrained by your busy work schedule or the logistic hassles associated with on-site donateer work.\n\n' 'Instead, you can dedicate your time at regular work toward the charity and then donate your salary-equivalent earnings from work to the charity of your choice. During the pledged hours at work, you are essentially earning donations for the charity. That\'s what we call "donateering"!\n\n' 'Donateering has many benefits beyond traditional forms of donations and donateer work. Charities can still benefit directly from you contributions like other types donations, but each of your donations will be directly associated with your work. Many people find that they enjoy their work more when they donateer - because it becomes more meaningful. Moreover, you won\'t easily forget about the donations that you made – we help you keep them in place so that your warm glow will keep growing :)\n\n',
                        ),
                    const SizedBox(height: 15),
                    Text('Be a donateer today!',
                        style: Theme.of(context).textTheme.headline1),
                    const Spacer(),
                    ElevatedButton(
                      child: const Text('PROCEED!'),
                      onPressed: () async {
                        Navigator.of(context)
                          .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TabsScreen(),
                            ),
                            (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }
}
