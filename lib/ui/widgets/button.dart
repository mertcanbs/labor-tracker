import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mware/models/process.dart';

import 'loader.dart';

const EdgeInsets _kButtonPadding = EdgeInsets.all(16.0);

class Button extends StatefulWidget {
  const Button({
    Key? key,
    required this.child,
    this.padding,
    this.margin = EdgeInsets.zero,
    this.color,
    this.textColor,
    this.shape,
    this.borderColor,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.alignment = Alignment.center,
    this.onPressed,
  })  : assert(pressedOpacity >= 0.0 && pressedOpacity <= 1.0),
        _filled = false,
        super(key: key);

  const Button.filled({
    Key? key,
    required this.child,
    this.padding,
    this.margin = EdgeInsets.zero,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.textColor,
    this.shape,
    this.borderColor,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.alignment = Alignment.center,
    this.onPressed,
  })  : assert(pressedOpacity >= 0.0 && pressedOpacity <= 1.0),
        color = null,
        _filled = true,
        super(key: key);

  const Button.dense({
    Key? key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = 36,
    this.color,
    this.textColor,
    this.shape,
    this.borderColor,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.alignment = Alignment.center,
    this.onPressed,
  })  : assert(pressedOpacity >= 0.0 && pressedOpacity <= 1.0),
        _filled = false,
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  final Color? textColor;

  final Color? borderColor;

  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry margin;

  final OutlinedBorder? shape;

  /// The color of the button's background.
  ///
  /// Defaults to null which produces a button with no background or border.
  ///
  /// Defaults to the [CupertinoTheme]'s `primaryColor` when the
  /// [ProtoTextButton.filled] constructor is used.
  final Color? color;

  /// The color of the button's background when the button is disabled.
  ///
  /// Ignored if the [Button] doesn't also have a [color].
  ///
  /// Defaults to [CupertinoColors.quaternarySystemFill] when [color] is
  /// specified. Must not be null.
  final Color disabledColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Minimum size of the button.
  ///
  /// Defaults to kMinInteractiveDimensionCupertino which the iOS Human
  /// Interface Guidelines recommends as the minimum tappable area.
  final double? minSize;

  /// The opacity that the button will fade to when it is pressed.
  /// The button will have an opacity of 1.0 when it is not pressed.
  ///
  /// This defaults to 0.4. If null, opacity will not change on pressed if using
  /// your own custom effects is desired.
  final double pressedOpacity;

  /// The radius of the button's corners when it has a background color.
  ///
  /// Defaults to round corners of 8 logical pixels.
  final BorderRadius borderRadius;

  /// The alignment of the button's [child].
  ///
  /// Typically buttons are sized to be just big enough to contain the child and its
  /// [padding]. If the button's size is constrained to a fixed size, for example by
  /// enclosing it with a [SizedBox], this property defines how the child is aligned
  /// within the available space.
  ///
  /// Always defaults to [Alignment.center].
  final AlignmentGeometry alignment;

  final bool _filled;

  /// Whether the button is enabled or disabled. Buttons are disabled by default. To
  /// enable a button, set its [onPressed] property to a non-null value.
  bool get enabled => onPressed != null;

  @override
  _ButtonState createState() => _ButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  // Eyeballed values. Feel free to tweak.
  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation =
        _animationController.drive(CurveTween(curve: Curves.decelerate)).drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(Button old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color? backgroundColor = widget.color == null
        ? (widget._filled ? primaryColor : null)
        : CupertinoDynamicColor.maybeResolve(widget.color, context);

    final Color? foregroundColor = enabled && widget.textColor != null
        ? widget.textColor
        : enabled
            ? backgroundColor == null || backgroundColor.computeLuminance() > 0.5
                ? primaryColor
                : Colors.white
            : CupertinoDynamicColor.resolve(CupertinoColors.placeholderText, context);

    final TextStyle textStyle =
        Theme.of(context).textTheme.button!.copyWith(color: foregroundColor);

    return Container(
      margin: widget.margin,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? _handleTapDown : null,
        onTapUp: enabled ? _handleTapUp : null,
        onTapCancel: enabled ? _handleTapCancel : null,
        onTap: widget.onPressed,
        child: Semantics(
          button: true,
          child: ConstrainedBox(
            constraints: widget.minSize == null
                ? const BoxConstraints()
                : BoxConstraints(
                    minWidth: widget.minSize!,
                    minHeight: widget.minSize!,
                  ),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: DecoratedBox(
                decoration: widget.shape != null
                    ? ShapeDecoration(
                        shape: widget.shape!,
                        color: backgroundColor != null && !enabled
                            ? CupertinoDynamicColor.resolve(widget.disabledColor, context)
                            : backgroundColor,
                      )
                    : BoxDecoration(
                        borderRadius: widget.borderRadius,
                        color: backgroundColor != null && !enabled
                            ? CupertinoDynamicColor.resolve(widget.disabledColor, context)
                            : backgroundColor,
                        border: widget.borderColor != null
                            ? Border.all(color: widget.borderColor!, width: 0.5)
                            : null,
                      ),
                child: Padding(
                  padding: widget.padding ?? _kButtonPadding,
                  child: Align(
                    alignment: widget.alignment,
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: DefaultTextStyle(
                      style: textStyle,
                      child: IconTheme(
                        data: IconThemeData(color: foregroundColor),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final String text;
  final Color? textColor;
  final Color? backgroundColor;

  final ProcessStatus processStatus;

  const SubmitButton({
    Key? key,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
    this.text = 'Submit',
    this.textColor,
    this.backgroundColor,
    this.processStatus = ProcessStatus.idle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child;
    Color color;

    switch (processStatus) {
      case ProcessStatus.processing:
        child = const Loader(size: 14, strokeWidth: 2);
        color = Colors.grey[200]!;
        break;
      case ProcessStatus.success:
        child = const Icon(Icons.check, size: 18, color: Colors.white);
        color = Theme.of(context).focusColor;
        break;
      case ProcessStatus.failure:
        child = const Icon(Icons.close, size: 18, color: Colors.white);
        color = Theme.of(context).errorColor;
        break;
      default:
        child = Text(
          text,
          style: TextStyle(color: textColor ?? Colors.white),
        );
        color = Theme.of(context).focusColor;
        break;
    }

    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.maxFinite,
        child: Button(
          pressedOpacity: 0.4,
          padding: const EdgeInsets.all(0),
          child: child,
          color: backgroundColor ?? color,
          onPressed: processStatus == ProcessStatus.idle ? onPressed : () {},
        ),
      ),
    );
  }
}
