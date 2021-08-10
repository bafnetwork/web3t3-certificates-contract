const [, , tokenId, recipientName, cohort, distinction] = process.argv;

if (!tokenId) {
  console.log(
    'usage: node generate_metadata.js <tokenId> <recipient_name> <cohort> <distinction>',
  );
  return;
}

const metadata = {
  name: 'Web3T3 Certificate',
  description:
    'Web3 Teacher Training Track Certificate of Completion, issued by the Blockchain Acceleration Foundation',
  external_url: 'https://certificates.web3.courses/certificate/' + tokenId,
  image: 'https://certificates.web3.courses/images/icon.png',
  attributes: [
    {
      trait_type: 'Recipient',
      value: recipientName,
    },
    {
      trait_type: 'Cohort',
      display_type: 'number',
      value: +cohort,
    },
    {
      trait_type: 'Issue Date',
      display_type: 'date',
      value: Date.now(),
    },
    {
      trait_type: 'Distinction',
      value: distinction,
    },
  ],
};

console.log(JSON.stringify(metadata));
