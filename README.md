# SummarizeIt
a


curl "https://qicwytf7g4466k8r.us-east-1.aws.endpoints.huggingface.cloud" \
-X POST \
-H "Accept: application/json" \
-H "Authorization: Bearer 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" \
-H "Content-Type: application/json" \
-d '{
    "inputs": "My name is Sarah Jessica Parker but you can call me Jessica",
    "parameters": {
        "aggregation_strategy": "simple"
    }
}'