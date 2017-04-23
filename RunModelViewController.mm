// Copyright 2015 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "RunModelViewController.h"

#include <fstream>
#include <pthread.h>
#include <unistd.h>
#include <queue>
#include <sstream>
#include <string>
#include <Photos/Photos.h>

#include "google/protobuf/io/coded_stream.h"
#include "google/protobuf/io/zero_copy_stream_impl.h"
#include "google/protobuf/io/zero_copy_stream_impl_lite.h"
#include "google/protobuf/message_lite.h"
#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/framework/tensor.h"
#include "tensorflow/core/framework/types.pb.h"
#include "tensorflow/core/platform/env.h"
#include "tensorflow/core/platform/logging.h"
#include "tensorflow/core/platform/mutex.h"
#include "tensorflow/core/platform/types.h"
#include "tensorflow/core/public/session.h"

#include "ios_image_load.h"
#include "ResultTableViewController.h"
#import "AssetGridViewController.h"

NSDictionary* RunInferenceOnImage(NSArray *,NSArray *, NSMutableArray *,UITextView *);
void save_image(NSMutableDictionary *result,NSString *key,int);

namespace {
class IfstreamInputStream : public ::google::protobuf::io::CopyingInputStream {
 public:
  explicit IfstreamInputStream(const std::string& file_name)
      : ifs_(file_name.c_str(), std::ios::in | std::ios::binary) {}
  ~IfstreamInputStream() { ifs_.close(); }

  int Read(void* buffer, int size) {
    if (!ifs_) {
      return -1;
    }
    ifs_.read(static_cast<char*>(buffer), size);
    return ifs_.gcount();
  }

 private:
  std::ifstream ifs_;
};
}  // namespace

@interface RunModelViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong,nonatomic) NSMutableArray *imageDataArray;

@end

@implementation RunModelViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.title = @"CLASSIFY IMAGES";
    
    /*UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    AssetGridViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AssetGridViewController"];
    [self.collectionTopView addSubview:vc.view];*/
    
}

- (IBAction)getUrl:(id)sender {
    NSDictionary* inference_result = RunInferenceOnImage(self.imageArray,self.assetArray,self.imageDataArray,self.urlContentTextView);
    ResultTableViewController *vc = [[ResultTableViewController alloc] init];
    vc.inference_result = inference_result;
    vc.imageArray = self.imageArray;
    vc.assetArray = self.assetArray;
    vc.imageDataArray = self.imageDataArray;
    [self.navigationController pushViewController:vc animated:YES];
    
    NSLog(@"sdsdsd");
    
    for( NSString *aKey in [inference_result allKeys] )
    {
        // do something like a log:
        NSLog(@"%@ : %lu",aKey,((NSMutableArray *)[inference_result objectForKey:aKey]).count);
    }
  //self.urlContentTextView.text = inference_result;
}

@end

// Returns the top N confidence values over threshold in the provided vector,
// sorted by confidence in descending order.
static void GetTopN(
    const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,
                           Eigen::Aligned>& prediction,
    const int num_results, const float threshold,
    std::vector<std::pair<float, int> >* top_results) {
  // Will contain top N results in ascending order.
  std::priority_queue<std::pair<float, int>,
      std::vector<std::pair<float, int> >,
      std::greater<std::pair<float, int> > > top_result_pq;

  const int count = prediction.size();
  for (int i = 0; i < count; ++i) {
    const float value = prediction(i);

    // Only add it if it beats the threshold and has a chance at being in
    // the top N.
    if (value < threshold) {
      continue;
    }

    top_result_pq.push(std::pair<float, int>(value, i));

    // If at capacity, kick the smallest value out.
    if (top_result_pq.size() > num_results) {
      top_result_pq.pop();
    }
  }

  // Copy to output vector and reverse into descending order.
  while (!top_result_pq.empty()) {
    top_results->push_back(top_result_pq.top());
    top_result_pq.pop();
  }
  std::reverse(top_results->begin(), top_results->end());
}


bool PortableReadFileToProto(const std::string& file_name,
                             ::google::protobuf::MessageLite* proto) {
  ::google::protobuf::io::CopyingInputStreamAdaptor stream(
      new IfstreamInputStream(file_name));
  stream.SetOwnsCopyingStream(true);
  // TODO(jiayq): the following coded stream is for debugging purposes to allow
  // one to parse arbitrarily large messages for MessageLite. One most likely
  // doesn't want to put protobufs larger than 64MB on Android, so we should
  // eventually remove this and quit loud when a large protobuf is passed in.
  ::google::protobuf::io::CodedInputStream coded_stream(&stream);
  // Total bytes hard limit / warning limit are set to 1GB and 512MB
  // respectively. 
  coded_stream.SetTotalBytesLimit(1024LL << 20, 512LL << 20);
  return proto->ParseFromCodedStream(&coded_stream);
}

NSString* FilePathForResourceName(NSString* name, NSString* extension) {
  NSString* file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
  if (file_path == NULL) {
    LOG(FATAL) << "Couldn't find '" << [name UTF8String] << "."
	       << [extension UTF8String] << "' in bundle.";
  }
  return file_path;
}

NSDictionary* RunInferenceOnImage(NSArray* imagePaths,NSArray *assetArray, NSMutableArray *imageDataArray, UITextView *textView) {
  tensorflow::SessionOptions options;

  tensorflow::Session* session_pointer = nullptr;
  tensorflow::Status session_status = tensorflow::NewSession(options, &session_pointer);
  if (!session_status.ok()) {
    std::string status_string = session_status.ToString();
      return @{@"error":[NSString stringWithFormat: @"Session create failed - %s",
                status_string.c_str()]};
  }
  std::unique_ptr<tensorflow::Session> session(session_pointer);
  LOG(INFO) << "Session created.";

  tensorflow::GraphDef tensorflow_graph;
  LOG(INFO) << "Graph created.";

  NSString* network_path = FilePathForResourceName(@"tensorflow_inception_graph", @"pb");
  PortableReadFileToProto([network_path UTF8String], &tensorflow_graph);

  LOG(INFO) << "Creating session.";
  tensorflow::Status s = session->Create(tensorflow_graph);
  if (!s.ok()) {
    LOG(ERROR) << "Could not create TensorFlow Graph: " << s;
      return @{@"error":@""};
  }

  // Read the label list
  NSString* labels_path = FilePathForResourceName(@"imagenet_comp_graph_label_strings", @"txt");
  std::vector<std::string> label_strings;
  std::ifstream t;
  t.open([labels_path UTF8String]);
  std::string line;
  while(t){
    std::getline(t, line);
    label_strings.push_back(line);
  }
  t.close();

  // Read the Grace Hopper image.
//  NSString* image_path = FilePathForResourceName(imageName, @"jpg");
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
    
    for(int i=0;i<imagePaths.count;i++) {
        textView.text = [NSString stringWithFormat:@"%d of %lu",i,imagePaths.count];
        UIImage* image_path = imagePaths[i];
        NSLog(@"==========================================================================================================");
//        NSLog(@"%@",image_path);
        int image_width;
        int image_height;
        int image_channels;
        CGImageRef imageref = [image_path CGImage];
        [imageDataArray addObject:UIImageJPEGRepresentation(image_path, 0.8)];
        std::vector<tensorflow::uint8> image_data = LoadImageFromFile(
                                                                      imageref, &image_width, &image_height, &image_channels);
        NSLog(@"fvdfgvd");
        const int wanted_width = 299;
        const int wanted_height = 299;
        const int wanted_channels = 3;
        const float input_mean = 128.0f;
        const float input_std = 128.0f;
        assert(image_channels >= wanted_channels);
        tensorflow::Tensor image_tensor(
                                        tensorflow::DT_FLOAT,
                                        tensorflow::TensorShape({
            1, wanted_height, wanted_width, wanted_channels}));
        auto image_tensor_mapped = image_tensor.tensor<float, 4>();
        tensorflow::uint8* in = image_data.data();
        tensorflow::uint8* in_end = (in + (image_height * image_width * image_channels));
        float* out = image_tensor_mapped.data();
        for (int y = 0; y < wanted_height; ++y) {
            const int in_y = (y * image_height) / wanted_height;
            tensorflow::uint8* in_row = in + (in_y * image_width * image_channels);
            float* out_row = out + (y * wanted_width * wanted_channels);
            for (int x = 0; x < wanted_width; ++x) {
                const int in_x = (x * image_width) / wanted_width;
                tensorflow::uint8* in_pixel = in_row + (in_x * image_channels);
                float* out_pixel = out_row + (x * wanted_channels);
                for (int c = 0; c < wanted_channels; ++c) {
                    out_pixel[c] = (in_pixel[c] - input_mean) / input_std;
                }
            }
        }
        
        NSString* result = [network_path stringByAppendingString: @" - loaded!"];
        result = [NSString stringWithFormat: @"%@ - %lu, %s - %dx%d", result,
                  label_strings.size(), label_strings[0].c_str(), image_width, image_height];
        
        std::string input_layer = "Mul";
        std::string output_layer = "final_result";
        std::vector<tensorflow::Tensor> outputs;
        tensorflow::Status run_status = session->Run({{input_layer, image_tensor}},
                                                     {output_layer}, {}, &outputs);
        if (!run_status.ok()) {
            LOG(ERROR) << "Running model failed: " << run_status;
            tensorflow::LogAllRegisteredKernels();
            result = @"Error running model";
            return @{@"error":result};
        }
        tensorflow::string status_string = run_status.ToString();
        result = [NSString stringWithFormat: @"%@ - %s", result,
                  status_string.c_str()];
        
        tensorflow::Tensor* output = &outputs[0];
        const int kNumResults = 15;
        const float kThreshold = 0.01f;
        std::vector<std::pair<float, int> > top_results;
        GetTopN(output->flat<float>(), kNumResults, kThreshold, &top_results);
        
        std::stringstream ss;
        ss.precision(3);
        bool found_medical_tag = false;
        bool already_saved_as_all_medical = false;
        for (const auto& result : top_results) {
            const float confidence = result.first;
            const int index = result.second;
            
            if (confidence <= 0.3) {
                if (!found_medical_tag) {
                    save_image(resultDictionary,@"Non Medical",i);
//                    save_image(resultDictionary,@"Non Medical_assets",assetArray);
                    NSLog(@"Non Medical saved as");
                }
                break;
            } else {
                if (index < label_strings.size()) {
                    if (![@"none" isEqualToString:@(label_strings[index].c_str())]) {
                        found_medical_tag = true;
                        if (![@"all_medical" isEqualToString:@(label_strings[index].c_str())]) {
                            save_image(resultDictionary,@(label_strings[index].c_str()),i);
//                            save_image(resultDictionary,[NSString stringWithFormat:@"%@_assets",@(label_strings[index].c_str())],assetArray);
                            NSLog(@"%@ saved as",@(label_strings[index].c_str()));
                        }
                        if (!already_saved_as_all_medical) {
                            already_saved_as_all_medical = true;
                            save_image(resultDictionary,@"all_medical",i);
//                            save_image(resultDictionary,@"all_medical_assets",assetArray);
                            NSLog(@"%@ saved as",@"all_medical");
                        }
                    }
                }
            }
            
            ss << index << " " << confidence << "  ";
            
            // Write out the result as a string
            if (index < label_strings.size()) {
                // just for safety: theoretically, the output is under 1000 unless there
                // is some numerical issues leading to a wrong prediction.
                ss << label_strings[index];
            } else {
                ss << "Prediction: " << index;
            }
            
            ss << "\n";
        }
        
        LOG(INFO) << "Predictions: " << ss.str();
        
        tensorflow::string predictions = ss.str();
        result = [NSString stringWithFormat: @"%@ - %s", result,
                  predictions.c_str()];

    }
    
    return resultDictionary;
}

void save_image(NSMutableDictionary *result,NSString *key,int toBeInserted) {
    if ([result objectForKey:key]) {
        NSMutableArray *originalArray = [result objectForKey:key];
        [originalArray addObject:@(toBeInserted)];
        [result setObject:originalArray forKey:key];
    } else {
        NSMutableArray *newArray = [NSMutableArray array];
        [newArray addObject:@(toBeInserted)];
        [result setObject:newArray forKey:key];
    }
}
