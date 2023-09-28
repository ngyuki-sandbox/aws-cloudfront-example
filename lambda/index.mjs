import * as crypto from 'crypto';
import * as querystring from 'querystring';

const key_pair_id = process.env.KEY_PAIR_ID;
const priv_key = process.env.PRIVATE_KEY;
const cf_domain = process.env.CF_DOMAIN;

export async function handler(event, context) {
    const date = new Date();
    const expires = date.getTime() + 300;
    const rawPath = event.rawPath.replace(/^\/[^\/]+\//, '');
    const url = `https://${cf_domain}/${rawPath}`;
    const link = signUrl(url, key_pair_id, priv_key, expires);
    return {
        statusCode: '200',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ date, link, event, context }),
    }
}

function sign(policy, priv_key) {
    const signer = crypto.createSign('RSA-SHA1');
    signer.update(JSON.stringify(policy));
    const signature = signer.sign(priv_key, 'base64');
    return signature;
}

function signUrl(url, key_pair_id, priv_key, expires) {
    const policy = {
        Statement: [
            {
                'Resource': url,
                'Condition': {
                    'DateLessThan': {
                        'AWS:EpochTime': expires,
                    },
                },
            },
        ],
    };
    const signature = sign(policy, priv_key);
    const qs = querystring.stringify({
        'Expires':     expires,
        'Signature':   signature,
        'Key-Pair-Id': key_pair_id,
    });
    return url + '?' + qs.toString();
}
