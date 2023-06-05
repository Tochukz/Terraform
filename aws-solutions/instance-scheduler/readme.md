# Instance Scheduler on AWS
[Solution Guide](https://aws.amazon.com/solutions/implementations/instance-scheduler-on-aws/)  
[Implementation Guide](https://docs.aws.amazon.com/solutions/latest/instance-scheduler-on-aws/solution-overview.html)   

__Overview__  
The Instance Scheduler on AWS solution automates the starting and stopping of Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Relational Database Service (Amazon RDS) instances.   
This solution helps reduce operational costs by stopping resources that are not in use and starting them when they are needed. The cost savings can be significant if you leave all of your instances running at full utilization continuously.

### Well-Architected design framework  
This section describes how the principles and best practices of the six pillar of the AWS Well-Architected Framework was applied when designing this solution.  

__Operational excellence__  
* The solution pushes metrics to Amazon CloudWatch to provide observability into its components (such as its infrastructure and Lambda functions).  
* AWS X-Ray traces Lambda functions.
* SNS for error reporting.

__Security__  
* All inter-service communications use IAM roles.
* All multi-account communications use IAM roles.
* All roles used by the solution follow least-privilege access. 
* All data storage including DynamoDB tables have encryption at rest.

__Reliability__  
* The solution uses serverless AWS services wherever possible (such as Lambda and DynamoDB) to ensure high availability and recovery from service failure.
* Data processing uses Lambda functions. The solution stores data in DynamoDB so it persists in multiple Availability Zones by default.

__Performance efficiency__  
* The solution uses serverless architecture
* You can launch the solution in any AWS Region that supports the AWS services used in this solution (such as Lambda and DynamoDB).

__Cost optimization__  
* The solution uses serverless architecture, and customers pay only for what they use.
* The compute layer defaults to Lambda, which uses a pay-per-use model.  

__Sustainability__  
* The solution uses managed and serverless services to minimize the environmental impact of the backend services.  
* The solution’s serverless design is aimed at reducing carbon footprint compared to the footprint of continually operating on-premises servers.