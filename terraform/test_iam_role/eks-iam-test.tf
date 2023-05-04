data "aws_iam_policy_document" "afoulger_iam_test_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "afoulger_test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.afoulger_iam_test_role_policy.json
  name               = "afoulger_test_oidc"
}

resource "aws_iam_policy" "afoulger_test_policy" {
  name = "afougler_test_policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "afoulger_test_attach" {
  role       = aws_iam_role.afoulger_test_oidc.name
  policy_arn = aws_iam_policy.afoulger_test_policy.arn
}

output "afoulger_test_policy_arn" {
  value = aws_iam_role.afoulger_test_oidc.arn
}
