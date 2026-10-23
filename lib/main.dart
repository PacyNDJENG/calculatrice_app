import 'package:flutter/material.dart';

void main() => runApp(const CalculatriceApp());

class Palette {
  static const fond = Colors.white;
  static const violetFonce = Color(0xFF7B2CBF);
  static const violet = Color(0xFF9D4EDD);
  static const violetClair = Color(0xFFE9D8FD);
  static const lavande = Color(0xFFF5EEFC);
  static const texte = Color(0xFF3C096C);
}

class CalculatriceApp extends StatelessWidget {
  const CalculatriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculatrice',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Palette.violet,
        scaffoldBackgroundColor: Palette.fond,
      ),
      home: const PageCalculatrice(),
    );
  }
}

class PageCalculatrice extends StatefulWidget {
  const PageCalculatrice({super.key});

  @override
  State<PageCalculatrice> createState() => _PageCalculatriceState();
}

class _PageCalculatriceState extends State<PageCalculatrice> {
  static const _operateurs = ['+', '-', '×', '÷'];

  String _output = '0';
  String _expression = '';
  double _num1 = 0;
  String _operand = '';
  bool _nouvelleSaisie = false; // vrai après un opérateur ou un "="

  // Affiche 5.0 -> "5" et 0.30000000000000004 -> "0.3"
  String _format(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e12) {
      return v.toInt().toString();
    }
    String s = v.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
  }

  double? _calculer(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? null : a / b;
    }
    return b;
  }

  void _erreur() {
    _output = 'Erreur';
    _expression = '';
    _operand = '';
    _num1 = 0;
    _nouvelleSaisie = true;
  }

  void _appui(String t) {
    setState(() {
      if (t == 'C') {
        _output = '0';
        _expression = '';
        _num1 = 0;
        _operand = '';
        _nouvelleSaisie = false;
      } else if (t == '⌫') {
        if (_nouvelleSaisie) return;
        _output = _output.length > 1 ? _output.substring(0, _output.length - 1) : '0';
        if (_output == '-') _output = '0';
      } else if (t == '±') {
        if (_output != '0' && _output != 'Erreur') {
          _output = _output.startsWith('-') ? _output.substring(1) : '-$_output';
        }
      } else if (t == '%') {
        if (_output != 'Erreur') {
          _output = _format(double.parse(_output) / 100);
        }
      } else if (_operateurs.contains(t)) {
        if (_output == 'Erreur') return;
        // Enchaîne les calculs : 2 + 3 + 4 …
        if (_operand.isNotEmpty && !_nouvelleSaisie) {
          final r = _calculer(_num1, double.parse(_output), _operand);
          if (r == null) {
            _erreur();
            return;
          }
          _num1 = r;
        } else {
          _num1 = double.parse(_output);
        }
        _operand = t;
        _output = _format(_num1);
        _expression = '${_format(_num1)} $t';
        _nouvelleSaisie = true;
      } else if (t == '=') {
        if (_operand.isEmpty || _nouvelleSaisie) return;
        final n2 = double.parse(_output);
        final r = _calculer(_num1, n2, _operand);
        if (r == null) {
          _erreur();
          return;
        }
        _expression = '${_format(_num1)} $_operand ${_format(n2)} =';
        _output = _format(r);
        _operand = '';
        _nouvelleSaisie = true;
      } else if (t == '.') {
        if (_nouvelleSaisie) {
          _output = '0.';
          _nouvelleSaisie = false;
        } else if (!_output.contains('.')) {
          _output += '.';
        }
      } else {
        // chiffre
        if (_nouvelleSaisie || _output == '0') {
          _output = t;
          _nouvelleSaisie = false;
        } else if (_output.length < 12) {
          _output += t;
        }
      }
    });
  }

  Widget _bouton(String t) {
    Color fond;
    Color texte;
    if (t == '=') {
      fond = Palette.violetFonce;
      texte = Colors.white;
    } else if (_operateurs.contains(t)) {
      fond = Palette.violet;
      texte = Colors.white;
    } else if (['C', '⌫', '±', '%'].contains(t)) {
      fond = Palette.violetClair;
      texte = Palette.violetFonce;
    } else {
      fond = Palette.lavande;
      texte = Palette.texte;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: fond,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _appui(t),
            child: Center(
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: texte,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const lignes = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['⌫', '0', '.', '='],
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Écran
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Palette.lavande,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: const TextStyle(fontSize: 20, color: Palette.violet),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _output,
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w700,
                          color: Palette.texte,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Clavier
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: Column(
                  children: [
                    for (final ligne in lignes)
                      Expanded(
                        child: Row(children: [for (final t in ligne) _bouton(t)]),
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
}