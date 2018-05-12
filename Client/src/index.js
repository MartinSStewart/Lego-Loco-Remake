import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

document.addEventListener("DOMContentLoaded", function(event) { 
        var elements = document.querySelectorAll( 'body > *' );
        for (var i = elements.length - 1; i >= 0; i--)
        {
            var element = elements[i];
            if (element.localName === "div" && element.id === "")
            {
                element.remove();
                break;
            }
        }
    });

Main.embed(document.getElementById('root'));

registerServiceWorker();