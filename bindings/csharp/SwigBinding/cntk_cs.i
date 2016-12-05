%module(directors="1") CSharpBindings
//%feature("autodoc", "1");

%include <stl.i>
%include <std_wstring.i>
%include <std_vector.i>
%include <std_map.i>
%include <std_pair.i>
%include <std_shared_ptr.i>
%include <windows.i>
%include <attribute.i>
%include <arrays_csharp.i>

// include the unordered_map.i.
%include "std_unordered_map.i"

%{
    #include "CNTKLibrary.h"
    #pragma warning(disable : 4100)
%}

%nspace CNTK;

%template(SizeTVector) std::vector<size_t>;
%template(BoolVector) std::vector<bool>;
%template(DoubleVector) std::vector<double>;
%template(FloatVector) std::vector<float>;
%template(SizeTVectorVector) std::vector<std::vector<size_t>>;
%template(FloatVectorVector) std::vector<std::vector<float>>;
%template(DoubleVectorVector) std::vector<std::vector<double>>;
%template(VariableVector) std::vector<CNTK::Variable>;
//%template() std::vector<CNTK::Parameter>;
//%template() std::vector<CNTK::Constant>;
%template(AxisVector) std::vector<CNTK::Axis>;
%template(DeviceDescriptorVector) std::vector<CNTK::DeviceDescriptor>;
//%template() std::vector<CNTK::StreamConfiguration>;

//%template() std::vector<CNTK::DictionaryValue>;

%template() std::vector<std::shared_ptr<CNTK::Function>>;
%template() std::vector<std::shared_ptr<CNTK::Learner>>;
%template() std::pair<size_t, double>;
%template() std::vector<std::pair<size_t, double>>;

%shared_ptr(CNTK::BackPropState);
%shared_ptr(CNTK::Function);
%shared_ptr(CNTK::CompositeFunction);
%shared_ptr(CNTK::Value);
%shared_ptr(CNTK::NDShape);
%shared_ptr(CNTK::NDArrayView);
%shared_ptr(CNTK::NDMask);
%shared_ptr(std::vector<float>);

// SWIG does not understand ValuePtr here.
%template(UnorderedMapVariableValuePtr) std::unordered_map<CNTK::Variable, std::shared_ptr<CNTK::Value>>;
%template(UnorderedMapVariableVariable) std::unordered_map<CNTK::Variable, CNTK::Variable>;

%ignore CNTK::IDictionarySerializable;
%ignore CNTK::DictionaryValue;
%ignore CNTK::Dictionary;
%ignore CNTK::ParameterInitializer;

%ignore CNTK::Parameter;
%ignore CNTK::Constant;
%ignore CNTK::PoolingType;
%ignore CNTK::TrainingParameterSchedule;
%ignore CNTK::TrainingParameterPerUnitSchedule;
%ignore CNTK::MomentumAsTimeConstantSchedule;
%ignore CNTK::AdditionalLearningOptions;
%ignore CNTK::Learner;
%ignore CNTK::Trainer;
%ignore CNTK::StreamInformation;
%ignore CNTK::MinibatchData;
%ignore CNTK::MinibatchSource;
%ignore CNTK::StreamConfiguration;
%ignore CNTK::DistributedWorkerDescriptor;
%ignore CNTK::DistributedCommunicator;
%ignore CNTK::QuantizedDistributedCommunicator;
%ignore CNTK::MinibatchInfo;
%ignore CNTK::DistributedTrainer;

// map the point to array
%apply float INPUT[]  { float *dataBuffer }
%apply double INPUT[]  { double *dataBuffer }


%typemap(csclassmodifiers) CNTK::Value "public partial class"

%pragma(csharp) moduleimports = %{

using System;
using System.Collections.Generic;

public partial class Value
{
    public static Value Create<T>(NDShape shape, List<List<T>> sequences, DeviceDescriptor computeDevice)
    {
        var dim = shape.TotalSize();

        if (typeof(T).Equals(typeof(float)))
        {
            var inputSeqVector = new FloatVectorVector();
            foreach (var seq in sequences)
            {
                if (seq.Count % dim != 0)
                {
                    throw new ArgumentException("the number of data in sequences does not match the input dimension");
                }
                var samples = new FloatVector(seq);
                inputSeqVector.Add(samples);
            }
            return Value.CreateDenseFloat(shape, inputSeqVector, computeDevice);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            var inputSeqVector = new DoubleVectorVector();
            foreach (var seq in sequences)
            {
                if (seq.Count % dim != 0)
                {
                    throw new ArgumentException("the number of data in sequences does not match the input dimension");
                }
                var samples = new DoubleVector(seq);
                inputSeqVector.Add(samples);
            }
            return Value.CreateDenseDouble(shape, inputSeqVector, computeDevice);
        }
        else
        {
            throw new ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value Create<T>(NDShape shape, List<List<long>> oneHotIndex, DeviceDescriptor computeDevice)
    {
        throw new NotImplementedException("Not implemented");
    }

    // Create Value based on sparse input
    // Todo: could this be a extension to Value class??
    // Todo: use Variable instead of varName. VarName as extension method
    public static Value Create<T>(NDShape shape, List<List<T>> data, List<List<long>> indexes, List<List<long>> nnzCounts, DeviceDescriptor computeDevice)
    {
        throw new NotImplementedException("Not implemented");
    }
}

%}

%include "CNTKLibraryInternals.h"
%include "CNTKLibrary.h"

//
// Value
//
%extend CNTK::Value {
    static CNTK::ValuePtr CNTK::Value::CreateDenseFloat(const CNTK::NDShape& sampleShape, const std::vector<std::vector<float>>& sequences, 
        const CNTK::DeviceDescriptor& device, bool readOnly = false) {
        return CNTK::Value::Create<float>(sampleShape, sequences, device, readOnly);
    }

    static CNTK::ValuePtr CNTK::Value::CreateDenseDouble(const CNTK::NDShape& sampleShape, const std::vector<std::vector<double>>& sequences, 
        const CNTK::DeviceDescriptor& device, bool readOnly = false) {
        return CNTK::Value::Create<double>(sampleShape, sequences, device, readOnly);
    }

    static CNTK::ValuePtr CNTK::Value::CreateOneHotFloat(size_t vocabularySize, const std::vector<std::vector<size_t>>& oneHotSequences, 
        const CNTK::DeviceDescriptor& device, bool readOnly = false) {
        return CNTK::Value::Create<float>(vocabularySize, oneHotSequences, device, readOnly);
    }

    static CNTK::ValuePtr CNTK::Value::CreateOneHotDouble(size_t vocabularySize, const std::vector<std::vector<size_t>>& oneHotSequences, 
        const CNTK::DeviceDescriptor& device, bool readOnly = false) {
        return CNTK::Value::Create<double>(vocabularySize, oneHotSequences, device, readOnly);
    }
}


//
// NDArryView
//
%extend CNTK::NDArrayView {
    NDArrayView(const NDShape& viewShape, float *dataBuffer, size_t numBufferElements, const DeviceDescriptor& device, bool readOnly = false)
    {
        return new CNTK::NDArrayView(CNTK::DataType::Float, viewShape, dataBuffer, numBufferElements * sizeof(float), device, readOnly);
    }

    NDArrayView(const NDShape& viewShape, double *dataBuffer, size_t numBufferElements, const DeviceDescriptor& device, bool readOnly = false)
    {
        return new CNTK::NDArrayView(CNTK::DataType::Double, viewShape, dataBuffer, numBufferElements * sizeof(double), device, readOnly);
    }
}

// 
// NDShape
//
%extend CNTK::NDShape {
    size_t GetDimensionSize(size_t axisId)
    {
        return (*self)[axisId];
    }
}

//
// Function
//
%extend CNTK::Function {
    ///
    /// Computes and stores the values of specified variables in the 'outputs' map, using provided 'inputs' values corresponding
    /// to each leaf variable of the function of VariableKind 'Input'.
    /// The function does not return any variables that needed for backpropagation of gradients.
    ///
    void Evaluate(const std::unordered_map<Variable, ValuePtr>& arguments,
                    std::unordered_map<Variable, ValuePtr>& outputs,
                    const DeviceDescriptor& computeDevice = DeviceDescriptor::UseDefaultDevice())
    {
        self->Forward(arguments, outputs, computeDevice, {});
    }
}

