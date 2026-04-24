enum SendFriendRequestOutcome { pending, friends }

class SendFriendRequestResult {
  const SendFriendRequestResult({
    required this.outcome,
    this.requestId,
  });

  final SendFriendRequestOutcome outcome;
  final String? requestId;
}
