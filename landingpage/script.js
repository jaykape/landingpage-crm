document.getElementById('contact-form').onsubmit = async (e) => {
  e.preventDefault();

  const payload = {
    first_name: document.getElementById('first_name').value,
    last_name: document.getElementById('last_name').value,
    email: document.getElementById('email').value,
    phone: document.getElementById('phone').value
  };

  try {
    const res = await fetch('https://your-api-id.execute-api.your-region.amazonaws.com/prod/submit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const text = await res.text();
    document.getElementById('response').innerText = text;
  } catch (error) {
    document.getElementById('response').innerText = 'Submission failed.';
    console.error('Error:', error);
  }
};
