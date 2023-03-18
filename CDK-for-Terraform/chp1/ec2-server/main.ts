import * as fs from "fs";
import * as path from "path";
import { Construct } from "constructs";
import { App, TerraformStack, CloudBackend, NamedCloudWorkspace, TerraformOutput } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { Instance } from "@cdktf/provider-aws/lib/instance";

class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new AwsProvider(this, "AWS", {
      region: "eu-west-2"
    });

    const ec2Instance = this.provisionEc2Instance();

    new TerraformOutput(this, "public_ip", {
      value: ec2Instance.publicIp,
    });
  }

  private provisionEc2Instance(): Instance {
    const userData = this.getScript();

    return new Instance(this, "compute", {
      ami: "ami-0f5470fce514b0d36",
      instanceType: 't2.nano',
      keyName: 'AmzLinuxKey2',
      securityGroups: [],
      tags: {
        Name: 'Chp1/Ec2Server',
      },
      userData,
    });
  }

  private getScript(): string {
    const scriptPath = path.join(__dirname, 'scripts/userdata.sh');
    const binaryStr = fs.readFileSync(scriptPath, "utf8");
    return binaryStr.toString();
  }
}

const app = new App();
const stack = new MyStack(app, "ec2-server");
new CloudBackend(stack, {
  hostname: "app.terraform.io",
  organization: "MyWebstation",
  workspaces: new NamedCloudWorkspace("ec2-server")
});
app.synth();
