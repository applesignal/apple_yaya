let currentState = 'waiting';

document.addEventListener('DOMContentLoaded', function() {
    const betButton = document.getElementById('bet-button');
    const multiplierButton = document.getElementById('multiplier-button');
    const readyButton = document.getElementById('ready-button');

    betButton.addEventListener('click', () => {
        if (currentState === 'betting') {
            fetch(`https://${GetParentResourceName()}/placeBet`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });

    multiplierButton.addEventListener('click', () => {
        if (currentState === 'playing') {
            fetch(`https://${GetParentResourceName()}/setMultiplier`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });

    readyButton.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/ready`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });
});

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'updateState') {
        currentState = data.state;
        updateUI();
    } else if (data.type === 'showCards') {
        showCards(data.cards);
    }
});

function updateUI()