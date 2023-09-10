class SimpleExpression {
  static final SimpleExpression _instance = SimpleExpression._();

  factory SimpleExpression() => _instance;

  SimpleExpression._();

  double evaluate(String expression) {
    try {
      expression = _handlePercentages(expression);
      List<String> tokens = _tokenize(expression);
      return _evaluateTokens(tokens);
    } catch (e) {
      throw 'Unable to evaluate the expression';
    }
  }

  String _handlePercentages(String expression) {
    RegExp percentagePattern = RegExp(r'(\d+(\.\d+)?)%');
    String modifiedExpression = expression;

    Iterable<Match> matches = percentagePattern.allMatches(expression);

    for (Match match in matches) {
      double percentageValue = double.parse(match.group(1)!) / 100;
      modifiedExpression = modifiedExpression.replaceFirst(
          match.group(0)!, percentageValue.toString());
    }

    return modifiedExpression;
  }

  List<String> _tokenize(String expression) {
    List<String> tokens = [];
    String currentToken = '';

    for (int i = 0; i < expression.length; i++) {
      if (_isOperator(expression[i]) || _isParenthesis(expression[i])) {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken);
          currentToken = '';
        }
        tokens.add(expression[i]);
      } else {
        currentToken += expression[i];
      }
    }

    if (currentToken.isNotEmpty) {
      tokens.add(currentToken);
    }

    return tokens;
  }

  bool _isOperator(String token) {
    return token == '+' || token == '-' || token == '*' || token == '/';
  }

  bool _isLeftParenthesis(String token) {
    return token == '(';
  }

  bool _isRightParenthesis(String token) {
    return token == ')';
  }

  bool _isParenthesis(String token) {
    return _isLeftParenthesis(token) || _isRightParenthesis(token);
  }

  double _evaluateTokens(List<String> tokens) {
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '-' &&
          (i == 0 ||
              _isOperator(tokens[i - 1]) ||
              _isLeftParenthesis(tokens[i - 1]))) {

        // Handle negative sign at the beginning or after an operator or left parenthesis
        tokens[i] = tokens[i] + tokens[i + 1];
        tokens.removeAt(i + 1);
      }
    }

    List<String> postfix = [];
    List<String> operatorStack = [];

    for (int i = 0; i < tokens.length; i++) {
      String token = tokens[i];
      if (_isNumeric(token)) {
        postfix.add(token);
      } else if (_isLeftParenthesis(token)) {
        operatorStack.add(token);
      } else if (_isRightParenthesis(token)) {
        while (operatorStack.isNotEmpty &&
            !_isLeftParenthesis(operatorStack.last)) {
          postfix.add(operatorStack.removeLast());
        }
        operatorStack.removeLast();
      } else if (_isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            _getPrecedence(operatorStack.last) >= _getPrecedence(token)) {
          postfix.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }

    while (operatorStack.isNotEmpty) {
      postfix.add(operatorStack.removeLast());
    }

    return _evaluatePostfix(postfix);
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null ||
        (str.startsWith('-') && double.tryParse(str.substring(1)) != null);
  }

  int _getPrecedence(String operator) {
    if (operator == '+' || operator == '-') {
      return 1;
    } else if (operator == '*' || operator == '/') {
      return 2;
    }
    return 0;
  }

  double _evaluatePostfix(List<String> postfix) {
    List<double> stack = [];

    for (String token in postfix) {
      if (_isNumeric(token)) {
        stack.add(double.parse(token));
      } else if (_isOperator(token)) {
        double operand2 = stack.removeLast();
        double operand1 = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(operand1 + operand2);
            break;
          case '-':
            stack.add(operand1 - operand2);
            break;
          case '*':
            stack.add(operand1 * operand2);
            break;
          case '/':
            stack.add(operand1 / operand2);
            break;
        }
      }
    }

    return stack.single;
  }
}
