class SimpleExpression {
  static final SimpleExpression _instance = SimpleExpression._();

  factory SimpleExpression() => _instance;

  SimpleExpression._();

  double evaluate(String expression) {
    try {
      expression = handlePercentages(expression);
      List<String> tokens = tokenize(expression);
      return evaluateTokens(tokens);
    } catch (e) {
      throw 'Unable to evaluate the expression';
    }
  }

  String handlePercentages(String expression) {
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

  List<String> tokenize(String expression) {
    List<String> tokens = [];
    String currentToken = '';

    for (int i = 0; i < expression.length; i++) {
      if (isOperator(expression[i]) || isParenthesis(expression[i])) {
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

  bool isOperator(String token) {
    return token == '+' || token == '-' || token == '*' || token == '/';
  }

  bool isLeftParenthesis(String token) {
    return token == '(';
  }

  bool isRightParenthesis(String token) {
    return token == ')';
  }

  bool isParenthesis(String token) {
    return isLeftParenthesis(token) || isRightParenthesis(token);
  }

  double evaluateTokens(List<String> tokens) {
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '-' &&
          (i == 0 ||
              isOperator(tokens[i - 1]) ||
              isLeftParenthesis(tokens[i - 1]))) {

        // Handle negative sign at the beginning or after an operator or left parenthesis
        tokens[i] = tokens[i] + tokens[i + 1];
        tokens.removeAt(i + 1);
      }
    }

    List<String> postfix = [];
    List<String> operatorStack = [];

    for (int i = 0; i < tokens.length; i++) {
      String token = tokens[i];
      if (isNumeric(token)) {
        postfix.add(token);
      } else if (isLeftParenthesis(token)) {
        operatorStack.add(token);
      } else if (isRightParenthesis(token)) {
        while (operatorStack.isNotEmpty &&
            !isLeftParenthesis(operatorStack.last)) {
          postfix.add(operatorStack.removeLast());
        }
        operatorStack.removeLast();
      } else if (isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            getPrecedence(operatorStack.last) >= getPrecedence(token)) {
          postfix.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }

    while (operatorStack.isNotEmpty) {
      postfix.add(operatorStack.removeLast());
    }

    return evaluatePostfix(postfix);
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null ||
        (str.startsWith('-') && double.tryParse(str.substring(1)) != null);
  }

  int getPrecedence(String operator) {
    if (operator == '+' || operator == '-') {
      return 1;
    } else if (operator == '*' || operator == '/') {
      return 2;
    }
    return 0;
  }

  double evaluatePostfix(List<String> postfix) {
    List<double> stack = [];

    for (String token in postfix) {
      if (isNumeric(token)) {
        stack.add(double.parse(token));
      } else if (isOperator(token)) {
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
