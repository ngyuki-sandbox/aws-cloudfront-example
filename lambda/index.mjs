
export async function handler(event, context) {
    const date = new Date();
    return {
        statusCode: '200',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ date, event, context }),
    }
}
