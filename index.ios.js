import React from "react";
import {
    NativeModules,
    ImageStore,
    requireNativeComponent,
    StyleSheet,
    I18nManager,
    View
} from "react-native";
import AppContainer from "AppContainer";

const RNCameraHostViewManager = NativeModules.RNCameraHostViewManager;

export default class RNCamera extends React.Component {
    static propTypes = {
        visible: React.PropTypes.bool,
        animationType: React.PropTypes.oneOf([ 'none', 'fade', 'slide' ]),

        onCancel: React.PropTypes.func,
        onCapture: React.PropTypes.func,
    };
    static defaultProps = {
        visible: false,
        animationType: 'slide'
    };
    static contextTypes = {
        rootTag: React.PropTypes.number,
    };

    capture() {
        RNCameraHostViewManager.capture();
    }

    _onCapture(event) {
        const { onCapture } = this.props;

        const { image, width, height } = event.nativeEvent;

        let captureEvent = {
            image: {
                path: image,
                width,
                height
            }
        };

        onCapture(captureEvent);
    }

    render() {
        const { visible, children, ...otherProps } = this.props;

        if (!visible) {
            return null;
        }

        const innerChildren = __DEV__ ? (
            <AppContainer rootTag={this.context.rootTag}>
                {children}
            </AppContainer>
        ) : children;

        return (
            <RNCameraHostView
                {...otherProps}
                onCapture={(event) => this._onCapture(event)}
                style={styles.modal}
                onStartShouldSetResponder={() => true}
            >
                <View
                    style={styles.container}
                >
                    {innerChildren}
                </View>
            </RNCameraHostView>
        )
    }
}

const RNCameraHostView = requireNativeComponent('RNCameraHostView', RNCamera);

const side = I18nManager.isRTL ? 'right' : 'left';
const styles = StyleSheet.create({
    modal: {
        position: 'absolute',
    },
    container: {
        position: 'absolute',
        [side] : 0,
        top: 0,
    }
});
