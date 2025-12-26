import { NgGooglePayWebview } from 'ng-google-pay-webview';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    NgGooglePayWebview.echo({ value: inputValue })
}
