import 'dart:io'; // Needed for exit functionality
import 'package:flutter/material.dart';

String pin = '1234';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 4 ATM Activity',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();
  String _pin = '';
  int _attempts = 0;

  void _login() {
    setState(() {
      _pin = _pinController.text;

      if (_pin == pin) {
        _showLoginSuccessDialog();
        _attempts = 0;
      } else {
        _attempts++;
        if (_attempts >= 3) {
          _showExceededAttemptsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid PIN!')),
          );
        }
      }
    });
  }

  void _showExceededAttemptsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Too Many Attempts'),
          content: const Text('You have exceeded the maximum number of attempts. The application will now exit.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                exit(0); // Exit the application
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _showLoginSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Successful'),
          content: const Text('You have successfully logged in!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int balance = 5000;
  int? amount;
  String? accountNumber;
  String? selectedService;

  void _balanceInquiry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Balance Inquiry'),
          content: Text('You currently have ₱ $balance in your account.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _withdraw() {
    _showTransactionDialog(
      title: 'Withdraw Cash',
      onConfirm: (int value) {
        if (value <= balance) {
          setState(() {
            balance -= value;
          });
          _showSnackbar('₱$value withdrawn. New balance: ₱$balance');
        } else {
          _showSnackbar('Insufficient balance.');
        }
      },
    );
  }

  void _deposit() {
    _showTransactionDialog(
      title: 'Deposit Money',
      onConfirm: (int value) {
        setState(() {
          balance += value;
        });
        _showSnackbar('₱$value deposited. New balance: ₱$balance');
      },
    );
  }

  void _changePin() {
    String? newPin;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Enter New PIN:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newPin = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (newPin != null && newPin!.length == 4) {
                  setState(() {
                    pin = newPin!;
                  });
                  _showSnackbar('PIN changed successfully.');
                } else {
                  _showSnackbar('Invalid PIN.');
                }
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _transferMoney() {
    String? accountNumber;
    _showTransferDialog(
      title: 'Transfer Money',
      onConfirm: (int value, String account) {
        if (value <= balance && account.isNotEmpty) {
          setState(() {
            balance -= value;
            accountNumber = account;
          });
          _showSnackbar('₱$value transferred to account $accountNumber. New balance: ₱$balance');
        } else if (account.isEmpty) {
          _showSnackbar('Invalid account number.');
        } else {
          _showSnackbar('Insufficient balance.');
        }
      },
    );
  }

  void _payBills() {
    _showPayBillsDialog(
      title: 'Pay Bills',
      onConfirm: (int value, String service) {
        if (value <= balance) {
          setState(() {
            balance -= value;
            selectedService = service;
          });
          _showSnackbar('₱$value paid to $selectedService. New balance: ₱$balance');
        } else {
          _showSnackbar('Insufficient balance.');
        }
      },
    );
  }

  void _exitApp() {
    exit(0); // Exits the application
  }

  void _showTransactionDialog({required String title, required Function(int) onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Amount'),
                onChanged: (value) {
                  amount = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (amount != null && amount! > 0) {
                  onConfirm(amount!);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog({required String title, required Function(int, String) onConfirm}) {
    String? accountNumber;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Enter Account Number:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  accountNumber = value;
                },
              ),
              const SizedBox(height: 20),
              const Text('Enter Amount:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (amount != null && amount! > 0 && accountNumber != null) {
                  onConfirm(amount!, accountNumber!);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showPayBillsDialog({required String title, required Function(int, String) onConfirm}) {
    String? selectedService;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Select Service:'),
              DropdownButton<String>(
                value: selectedService,
                items: <String>['Meralco', 'Maya', 'Globe', 'PLDT'].map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedService = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (selectedService != null) // Display the selected service if it is not null
                Text(
                  'Selected Service: $selectedService',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              const Text('Enter Amount:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (amount != null && amount! > 0 && selectedService != null) {
                  onConfirm(amount!, selectedService!);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: <Widget>[
          _buildFeatureCard(Icons.account_balance, 'Balance Inquiry', _balanceInquiry),
          _buildFeatureCard(Icons.money, 'Withdraw', _withdraw),
          _buildFeatureCard(Icons.payment, 'Deposit', _deposit),
          _buildFeatureCard(Icons.account_circle, 'Change PIN', _changePin), // Change PIN feature added
          _buildFeatureCard(Icons.transfer_within_a_station, 'Transfer Money', _transferMoney),
          _buildFeatureCard(Icons.receipt, 'Pay Bills', _payBills),
          _buildFeatureCard(Icons.exit_to_app, 'Exit', _exitApp),
        ],
      ),
    );
  }

  Card _buildFeatureCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.tealAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 48.0, color: Colors.teal),
              const SizedBox(height: 20),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
